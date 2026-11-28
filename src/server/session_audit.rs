//! Auditoria local de sessões do DRGinfo Acesso Remoto (Fase 1).
//!
//! Grava metadados de cada sessão em JSONL, um arquivo por dia (UTC), e aplica
//! retenção exata de 90 dias pelo timestamp de cada evento.
//! Nunca grava senha, token, chave ou conteúdo remoto.
//! Falhas são registradas em log e não interrompem a conexão (fail-open).

use chrono::{DateTime, Duration, Utc};
use hbb_common::ResultType;
use serde_json::{json, Value};
use std::{
    fs::{self, OpenOptions},
    io::{self, Write},
    path::{Path, PathBuf},
    sync::OnceLock,
    time::Duration as StdDuration,
};

use crate::platform::windows::acl::{acquire_named_mutex, create_audit_directory, replace_file};

// Pasta da aplicação, criada pelo instalador em ProgramData.
const APP_DIR: &str = "DRGinfo Acesso Remoto";
// Mutex nomeado global: protege gravação e purga entre processos servidores.
const MUTEX_NAME: &str = "Global\\DRGinfo.AcessoRemoto.Auditoria";
// Espera máxima pelo mutex. Ao estourar, a operação vira erro em log (fail-open).
const LOCK_TIMEOUT_MS: u32 = 5_000;
// Retenção em dias corridos, contados pelo timestamp individual de cada evento.
const RETENTION_DAYS: i64 = 90;
// Intervalo entre purgas enquanto o processo servidor estiver ativo.
const PURGE_INTERVAL: StdDuration = StdDuration::from_secs(60 * 60);
// Limite de caracteres para campos vindos do acessante.
const MAX_FIELD_CHARS: usize = 256;

// Garante que a thread de manutenção seja iniciada uma única vez por processo.
static WORKER: OnceLock<()> = OnceLock::new();

pub struct SessionEvent<'a> {
    pub session_id: &'a str,
    pub peer_id: &'a str,
    pub peer_name: &'a str,
    pub origin_ip: &'a str,
    pub mode: &'a str,
    pub result: &'a str,
    pub started: DateTime<Utc>,
    pub finished: Option<DateTime<Utc>>,
}

fn audit_dir() -> io::Result<PathBuf> {
    let base = std::env::var_os("PROGRAMDATA")
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "PROGRAMDATA indisponível"))?;
    Ok(PathBuf::from(base)
        .join(APP_DIR)
        .join("auditoria")
        .join("sessoes"))
}

// Cria cada nível da hierarquia com DACL protegida, do topo para a folha.
// Níveis já existentes são mantidos sem alteração.
fn ensure_tree(dir: &Path) -> ResultType<()> {
    let mut levels: Vec<&Path> = dir.ancestors().take(3).collect();
    levels.reverse();
    for level in levels {
        create_audit_directory(level)?;
    }
    Ok(())
}

fn truncate(value: &str) -> String {
    value.chars().take(MAX_FIELD_CHARS).collect()
}

fn record_value(event: &SessionEvent<'_>) -> Value {
    let origin_ip = if event.origin_ip.is_empty() {
        "indisponivel"
    } else {
        event.origin_ip
    };
    json!({
        "schema_version": 1,
        "session_id": event.session_id,
        "peer_id": truncate(event.peer_id),
        "peer_name": truncate(event.peer_name),
        "origin_ip": origin_ip,
        "started_at_utc": event.started.to_rfc3339(),
        "finished_at_utc": event.finished.map(|t| t.to_rfc3339()),
        "duration_seconds": event.finished.map(|t| (t - event.started).num_seconds().max(0)),
        "mode": event.mode,
        "result": event.result,
    })
}

/// Registra um evento. Qualquer falha vai para o log e não é propagada à sessão.
pub fn write_event(event: &SessionEvent<'_>) {
    if let Err(err) = write_event_inner(event) {
        log::error!("DRGinfo auditoria: falha ao gravar evento: {err}");
    }
}

fn write_event_inner(event: &SessionEvent<'_>) -> ResultType<()> {
    let dir = audit_dir()?;
    ensure_tree(&dir)?;
    // O mutex é liberado ao sair de escopo, inclusive em erro.
    let _lock = acquire_named_mutex(MUTEX_NAME, LOCK_TIMEOUT_MS)?;
    let file_path = dir.join(format!("{}.jsonl", Utc::now().format("%Y-%m-%d")));
    // Linha completa com terminador LF, montada antes da escrita: uma única chamada write_all.
    let mut line = serde_json::to_vec(&record_value(event))?;
    line.push(b'\n');
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&file_path)?;
    file.write_all(&line)?;
    // sync_data força a gravação no disco antes de liberar o mutex.
    file.sync_data()?;
    Ok(())
}

/// Remove registros com mais de 90 dias. Devolve quantos foram removidos.
pub fn purge_expired(now: DateTime<Utc>) -> ResultType<usize> {
    let dir = audit_dir()?;
    if !dir.is_dir() {
        return Ok(0);
    }
    let _lock = acquire_named_mutex(MUTEX_NAME, LOCK_TIMEOUT_MS)?;
    let cutoff = now - Duration::days(RETENTION_DAYS);
    let mut removed_total = 0usize;
    for entry in fs::read_dir(&dir)? {
        let path = entry?.path();
        if path.extension().and_then(|e| e.to_str()) != Some("jsonl") {
            continue;
        }
        removed_total += purge_file(&dir, &path, cutoff)?;
    }
    Ok(removed_total)
}

fn purge_file(dir: &Path, path: &Path, cutoff: DateTime<Utc>) -> ResultType<usize> {
    let content = fs::read_to_string(path)?;
    let mut kept: Vec<&str> = Vec::new();
    let mut removed = 0usize;
    for line in content.lines() {
        if line.trim().is_empty() {
            continue;
        }
        if keep_line(line, cutoff) {
            kept.push(line);
        } else {
            removed += 1;
        }
    }
    if removed == 0 {
        return Ok(0);
    }
    if kept.is_empty() {
        fs::remove_file(path)?;
        return Ok(removed);
    }
    // Reescrita: temporário no mesmo diretório (herda a DACL), depois substituição atômica.
    // O original só é substituído depois que o temporário foi gravado e sincronizado.
    let tmp = dir.join(format!(".tmp-{}.jsonl", uuid::Uuid::new_v4()));
    let result = write_temp_and_replace(&tmp, path, &kept);
    if result.is_err() {
        let _ = fs::remove_file(&tmp);
    }
    result?;
    Ok(removed)
}

// Linha ilegível ou sem timestamp é preservada: não apagamos evidência sem certeza.
fn keep_line(line: &str, cutoff: DateTime<Utc>) -> bool {
    let Ok(value) = serde_json::from_str::<Value>(line) else {
        return true;
    };
    let Some(started) = value.get("started_at_utc").and_then(|v| v.as_str()) else {
        return true;
    };
    match DateTime::parse_from_rfc3339(started) {
        Ok(t) => t.with_timezone(&Utc) >= cutoff,
        Err(_) => true,
    }
}

fn write_temp_and_replace(tmp: &Path, target: &Path, lines: &[&str]) -> ResultType<()> {
    let mut buf = String::new();
    for line in lines {
        buf.push_str(line);
        buf.push('\n');
    }
    let mut file = OpenOptions::new().create_new(true).write(true).open(tmp)?;
    file.write_all(buf.as_bytes())?;
    file.sync_all()?;
    drop(file);
    replace_file(tmp, target)
}

/// Inicia a manutenção (purga na inicialização e a cada hora). Idempotente.
pub fn start_maintenance_worker() {
    WORKER.get_or_init(|| {
        std::thread::spawn(|| loop {
            match purge_expired(Utc::now()) {
                Ok(0) => {}
                Ok(n) => log::info!("DRGinfo auditoria: {n} registro(s) expirado(s) removido(s)"),
                Err(err) => log::error!("DRGinfo auditoria: falha na retenção: {err}"),
            }
            std::thread::sleep(PURGE_INTERVAL);
        });
    });
}
