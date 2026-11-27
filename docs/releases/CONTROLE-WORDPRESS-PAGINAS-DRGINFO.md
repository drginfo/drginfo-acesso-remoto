# DRGinfo — Controle de publicação WordPress
Site: https://drginfo.com.br · Hospedagem Hostinger · WordPress auto-hospedado.
## Páginas
- WordPress ID 924: https://drginfo.com.br/acesso-remoto/ — SAC: sac@drginfo.com.br.
- WordPress ID 923: https://drginfo.com.br/privacidade-acesso-remoto/ — LGPD: privacidade@drginfo.com.br.
- Conteúdo HTML original do operador; não inventar políticas de privacidade adicionais.
## Histórico operacional
- Rascunhos criados por API REST com senha de aplicativo (não versionar credencial).
- Publicação status `draft -> publish` pela API; após publicação, CSS em `Aparência > Personalizar > CSS adicional` precisou ser reaplicado devido a diferença de renderização.
- Logotipo duplicado era widget Elementor apontando para `/wp-content/uploads/2023/10/drg-logo-colorida-v2-1.png`, e NÃO a imagem embutida no HTML.
- Operador confirmou a correção visual.
## Regras direcionadas de ocultação
```css
/* Apenas IDs 923 e 924 — não atingir o restante do site */
body.page-id-923 .elementor-widget-image img[src*="drg-logo-colorida"],
body.page-id-924 .elementor-widget-image img[src*="drg-logo-colorida"] {
    display: none !important;
}
```
Estas regras são somente o **complemento final**; as demais regras de aparência foram copiadas de arquivos HTML e inseridas pelo operador no WordPress.
## Backup necessário
1. Exportar o CSS adicional real completo e versionar um snapshot sem credenciais.
2. Exportar as páginas `923`/`924` com `content.raw` e metadados, sanitizando conteúdo não público.
3. Registrar versão de Elementor/tema/cache e limpar cache LiteSpeed somente após alterações, evitando impactar outras páginas.
4. Verificar acesso anônimo, HTTPS, mobile, links, cores, logo e versão do código-fonte indicado na página.
5. Política LGPD deve corresponder à operação de coleta/retenção de dados; avaliação jurídica/operacional antes de tratar como conformidade certificada.
