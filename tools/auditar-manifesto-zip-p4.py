#!/usr/bin/env python3
"""DRGinfo: confere manifesto-sha256.csv contra bytes do ZIP sem extrair.
Biblioteca padrao Python 3. Nenhum arquivo do ZIP e executado.
"""
import argparse
import csv
import hashlib
import io
import re
import sys
import zipfile
from datetime import datetime
from pathlib import Path, PurePosixPath

DEFAULT_ZIP = Path.home() / "projetos/Drginfo/DRGinfo-Acesso-Remoto-Windows-x64.zip"
EXPECTED_ZIP_SHA256 = "926faa9759236e18d4f5791a4a3be76f0c96973676904f6f5fe08d8aa50b533a"
SHA_PATTERN = re.compile(r"^[0-9a-fA-F]{64}$")


def sha256_stream(handle):
    digest = hashlib.sha256()
    while True:
        chunk = handle.read(1024 * 1024)
        if not chunk:
            return digest.hexdigest()
        digest.update(chunk)


def valid_zip_name(name):
    p = PurePosixPath(name)
    return bool(name) and not name.startswith(("/", "\\")) and not re.match(
        r"^[a-zA-Z]:", name
    ) and "\\" not in name and ":" not in name and all(
        part not in ("", ".", "..") for part in name.rstrip("/").split("/")
    )


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("zip_path", nargs="?", type=Path, default=DEFAULT_ZIP)
    parser.add_argument("--expected-sha256", default=EXPECTED_ZIP_SHA256,
                        help="SHA-256 do ZIP obtido por canal independente")
    args = parser.parse_args()
    zip_path = args.zip_path.expanduser().resolve()
    if not zip_path.is_file():
        parser.error(f"ZIP inexistente: {zip_path}")
    if not SHA_PATTERN.fullmatch(args.expected_sha256):
        parser.error("--expected-sha256 exige exatamente 64 caracteres hexadecimais")
    issues = []
    warnings = []
    lines = []
    zip_hash = None
    records = []
    matched = 0
    unlisted = []

    with zip_path.open("rb") as file_handle:
        zip_hash = sha256_stream(file_handle)
    if zip_hash.lower() != args.expected_sha256.lower():
        issues.append("SHA-256 do ZIP diverge da referencia independente.")

    try:
        with zipfile.ZipFile(zip_path, "r") as archive:
            info_list = archive.infolist()
            names = [entry.filename for entry in info_list if not entry.is_dir()]
            if len(names) != len(set(names)):
                issues.append("ZIP contem nomes de arquivo duplicados.")
            for info in info_list:
                if not valid_zip_name(info.filename):
                    issues.append(f"Nome inseguro no ZIP: {info.filename!r}")
                if (info.external_attr >> 16) & 0o170000 == 0o120000:
                    issues.append(f"Link simbolico no ZIP: {info.filename!r}")
            if "manifesto-sha256.csv" not in names:
                issues.append("manifesto-sha256.csv ausente na raiz.")
            else:
                raw = archive.read("manifesto-sha256.csv")
                reader = csv.DictReader(io.StringIO(raw.decode("utf-8-sig")))
                if not reader.fieldnames or not {"Arquivo", "SHA256"}.issubset(reader.fieldnames):
                    issues.append("CSV nao contem as colunas Arquivo e SHA256.")
                else:
                    records = list(reader)
                    covered = set()
                    for index, record in enumerate(records, start=2):
                        name = (record.get("Arquivo") or "").strip().replace("\\", "/")
                        want = (record.get("SHA256") or "").strip()
                        if not valid_zip_name(name) or name == "manifesto-sha256.csv":
                            issues.append(f"Linha {index}: caminho de manifesto invalido: {name!r}")
                            continue
                        if name in covered:
                            issues.append(f"Linha {index}: arquivo duplicado no manifesto: {name}")
                            continue
                        covered.add(name)
                        if not SHA_PATTERN.fullmatch(want):
                            issues.append(f"Linha {index}: SHA-256 invalido: {name}")
                            continue
                        if name not in names:
                            issues.append(f"Linha {index}: arquivo nao encontrado no ZIP: {name}")
                            continue
                        with archive.open(name) as item:
                            found = sha256_stream(item)
                        if found.lower() != want.lower():
                            issues.append(f"Linha {index}: HASH DIVERGENTE: {name}")
                        else:
                            matched += 1
                    unlisted = sorted(set(names) - covered - {"manifesto-sha256.csv"})
                    if unlisted:
                        warnings.append(
                            f"{len(unlisted)} arquivos do ZIP nao constam no manifesto interno; "
                            "a cobertura e parcial."
                        )
    except (OSError, UnicodeError, zipfile.BadZipFile, RuntimeError, ValueError) as exc:
        issues.append(f"Falha ao processar ZIP/manifesto: {type(exc).__name__}: {exc}")

    status = "FALHA" if issues else "APROVADO_COM_RESSALVAS" if warnings else "APROVADO"
    lines.extend([
        "# DRGinfo — Auditoria integral do manifesto ZIP P4",
        "",
        f"- Data/hora: `{datetime.now().astimezone().isoformat(timespec='seconds')}`",
        f"- ZIP: `{zip_path}`",
        f"- SHA-256 ZIP calculado: `{zip_hash}`",
        f"- SHA-256 ZIP de referencia: `{args.expected_sha256.lower()}`",
        f"- Entradas listadas no manifesto: **{len(records)}**",
        f"- Entradas do manifesto com hash correspondente: **{matched}**",
        f"- Entradas fora do manifesto: **{len(unlisted)}**",
        f"- Resultado: **{status}**",
        "",
        "## Falhas", *((f"- {v}" for v in issues) if issues else ["- Nenhuma"]),
        "",
        "## Ressalvas", *((f"- {v}" for v in warnings) if warnings else ["- Nenhuma"]),
        "",
        "## Arquivos não listados no manifesto (primeiros 25)",
        *((f"- `{v}`" for v in unlisted[:25]) if unlisted else ["- Nenhum"]),
        "",
        "## Limites",
        "- Verificacao local dos bytes e hashes: NAO prova autoria, commit de compilacao, assinatura, ausencia de malware, integridade da origem do SHA de referencia, funcionalidade nem homologacao Windows.",
        "- Nenhum arquivo do ZIP foi extraido ou executado.",
    ])
    output = zip_path.with_name("AUDITORIA-MANIFESTO-DRGinfo-P4.md")
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"RESULTADO={status}")
    print(f"HASHES_VALIDOS={matched}/{len(records)}")
    print(f"ARQUIVOS_FORA_MANIFESTO={len(unlisted)}")
    print(f"RELATORIO={output}")
    return 1 if issues else 0


if __name__ == "__main__":
    sys.exit(main())
