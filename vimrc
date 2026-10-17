" ╭──────────────────────────────────────────────────────────────────────────╮
" │  vimrc — punto de entrada                                                │
" │                                                                          │
" │  Aquí NO hay configuración, solo el ORDEN DE CARGA. Cada pieza vive en   │
" │  su propio archivo (mira README.md para el mapa completo).               │
" │                                                                          │
" │  Tu ~/.vimrc solo necesita una línea:                                    │
" │      source ~/.config/vim/vimrc                                          │
" ╰──────────────────────────────────────────────────────────────────────────╯
if exists('g:loaded_my_config') | finish | endif
let g:loaded_my_config = 1

set encoding=utf-8
scriptencoding utf-8

" Raíz de la config. Se calcula a partir de este archivo (siguiendo symlinks),
" así la carpeta funciona esté donde esté: ~/.config/vim, un repo de dotfiles...
let g:my_root = fnamemodify(resolve(expand('<sfile>:p')), ':h')

" Nuestra carpeta primero en el runtimepath: autoload/, after/, colors/ ...
let &runtimepath = g:my_root . ',' . &runtimepath . ',' . g:my_root . '/after'

" Estado (undo, swap, viminfo) FUERA de la config → la carpeta se puede versionar
let g:my_state = (empty($XDG_STATE_HOME) ? $HOME . '/.local/state' : $XDG_STATE_HOME) . '/vim'
for s:d in ['undo', 'swap']
  silent! call mkdir(g:my_state . '/' . s:d, 'p', 0700)
endfor

" Registro de atajos (lo rellena my#keys#map(); lo usan <leader>? y el which-key)
let g:my_keys = []

" Carga un archivo; si falla, avisa pero NO rompe el resto de la config.
function! s:source(file) abort
  if !filereadable(a:file) | return | endif
  try
    execute 'source' fnameescape(a:file)
  catch
    echohl ErrorMsg
    echom '[config] ' . fnamemodify(a:file, ':t') . ': ' . v:exception . ' (' . v:throwpoint . ')'
    echohl None
  endtry
endfunction

" 1) Ajustes de esta máquina (variables: g:my_flavor, g:my_nerdfont...). Ver local.vim.example
call s:source(g:my_root . '/local.vim')

" 2) Módulos, en orden. Añadir uno = crear config/<nombre>.vim y listarlo aquí.
for s:m in ['options', 'keys', 'languages', 'plugins', 'ui', 'terminal', 'autocmds']
  call s:source(g:my_root . '/config/' . s:m . '.vim')
endfor

" 3) Extras de esta máquina que necesitan que todo esté cargado (mapeos propios...)
call s:source(g:my_root . '/local.after.vim')
