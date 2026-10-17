" ── after/ftplugin/sh.vim ── opciones del buffer para bash/sh ─────────────────
setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2
setlocal foldmethod=indent
setlocal iskeyword+=-                          " que `-` cuente como parte de la palabra
setlocal keywordprg=:Man                       " K sin LSP: página man
