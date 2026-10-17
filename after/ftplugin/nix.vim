" ── after/ftplugin/nix.vim ── opciones del buffer para Nix ─────────────────────
setlocal expandtab shiftwidth=2 softtabstop=2 tabstop=2
setlocal commentstring=#\ %s
setlocal foldmethod=indent
setlocal iskeyword+=-,'                        " nombres como pkgs-unstable o foo'
