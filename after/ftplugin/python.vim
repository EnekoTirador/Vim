" ── after/ftplugin/python.vim ── opciones del buffer para Python ───────────────
" (Va en after/ para ganar al ftplugin que trae Vim. Qué ejecutar/formatear/LSP
"  está en config/languages.vim.)
setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=4
setlocal textwidth=88 colorcolumn=89           " ancho de black / ruff format
setlocal formatoptions-=t                      " no cortar líneas solo: lo hace el formateador
setlocal foldmethod=indent
setlocal keywordprg=python3\ -m\ pydoc         " K sin LSP: documentación con pydoc
