" ── plugins/lang.vim ── sintaxis que Vim no trae de serie ─────────────────────
" Python y bash ya vienen bien cubiertos por Vim (sintaxis, indentado).
" Para Nix, vim-nix aporta sintaxis + indentado fiables. Carga solo en archivos .nix.
Plug 'LnL7/vim-nix', { 'for': 'nix' }
