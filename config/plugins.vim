" ── config/plugins.vim ── gestor de plugins ────────────────────────────────────
" Usamos vim-plug (viene incluido en autoload/plug.vim: funciona sin internet).
" Los plugins se descargan DENTRO de esta carpeta, en ./plugged  (ignorada por git).
"
" Cada archivo de plugins/*.vim declara sus propios plugins con `Plug '...'` y
" su configuración. Para añadir uno: crea plugins/<nombre>.vim. Para quitarlo:
" borra el archivo y ejecuta :PlugClean.

let g:plug_home = g:my_root . '/plugged'
let g:plug_shallow = 1                     " clones superficiales: instalación rápida

call plug#begin(g:plug_home)
for s:f in sort(glob(g:my_root . '/plugins/*.vim', 0, 1))
  try
    execute 'source' fnameescape(s:f)
  catch
    echohl ErrorMsg
    echom '[plugins] ' . fnamemodify(s:f, ':t') . ': ' . v:exception . ' (' . v:throwpoint . ')'
    echohl None
  endtry
endfor
call plug#end()

" ── Primer arranque en una máquina nueva: instala lo que falte ───────────────
" (se puede desactivar con  let g:my_no_autoinstall = 1  en local.vim)
function! s:first_run() abort
  let l:missing = filter(copy(g:plugs), {_, p -> !isdirectory(p.dir)})
  if empty(l:missing) | return | endif
  echo 'Primer arranque: instalando plugins (' . join(keys(l:missing), ', ') . ')...'
  redraw
  PlugInstall --sync
  " Cierra la ventana de progreso y activa los plugins recién instalados sin reiniciar
  for l:w in range(1, winnr('$'))
    if getwinvar(l:w, '&filetype') ==# 'vim-plug' | execute l:w . 'close' | break | endif
  endfor
  for l:p in values(l:missing)
    if !isdirectory(l:p.dir) | continue | endif
    for l:f in globpath(l:p.dir, 'plugin/**/*.vim', 0, 1)
      execute 'silent! source' fnameescape(l:f)
    endfor
  endfor
  silent! filetype detect
  call my#ui#colorscheme(g:my_flavor)
  redraw
  echo 'Plugins instalados ✔  (si algo no responde, reinicia Vim)'
endfunction

let s:auto = !get(g:, 'my_no_autoinstall', !empty($MY_VIM_NO_AUTOINSTALL))
if has('vim_starting') && s:auto && executable('git')
  augroup MyFirstRun
    autocmd!
    autocmd VimEnter * ++once call s:first_run()
  augroup END
endif
