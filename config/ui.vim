" ── config/ui.vim ── tema, statusline y bufferline ─────────────────────────────
" Va DESPUÉS de cargar los plugins porque el tema vive en un plugin.
" La lógica está en autoload/my/ui.vim; aquí solo se conecta.

let g:my_flavor = get(g:, 'my_flavor', 'mocha')     " mocha | macchiato | frappe | latte
let g:my_nerdfont = get(g:, 'my_nerdfont', 1)       " 0 si tu terminal no usa una Nerd Font

augroup MyUi
  autocmd!
  " Cada vez que cambia el tema, recalcula nuestros colores (statusline, popups...)
  autocmd ColorScheme * call my#ui#highlights()
augroup END

call my#ui#colorscheme(g:my_flavor)

set statusline=%!my#ui#statusline()
set tabline=%!my#ui#tabline()
call my#ui#tabline_visibility()
