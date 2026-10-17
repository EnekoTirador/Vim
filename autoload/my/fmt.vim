" ── autoload/my/fmt.vim ── formatear y limpiar ─────────────────────────────────
scriptencoding utf-8

" Formatea el buffer con el primer formateador instalado del registro.
" Usa un filtro stdin→stdout: no toca el disco y conserva la posición del cursor.
" Si no hay formateador, prueba el LSP. my#fmt#buffer(1) = en silencio (al guardar).
function! my#fmt#buffer(...) abort
  let l:quiet = a:0 && a:1
  let l:cmd = my#lang#pick(get(my#lang#get(&filetype), 'fmt', []))
  if empty(l:cmd)
    if !l:quiet
      if exists('*LspServerReady') && LspServerReady() && exists(':LspFormat')
        LspFormat
      else
        echohl WarningMsg | echo 'Sin formateador para "' . &filetype . '" (mira :Doctor)' | echohl None
      endif
    endif
    return
  endif

  let l:in = getline(1, '$')
  let l:out = systemlist(my#lang#expand(l:cmd), l:in)
  if v:shell_error
    echohl ErrorMsg | echom my#lang#bin(l:cmd) . ' falló: ' . join(l:out[0 : 2], ' ⏎ ') | echohl None
    return
  endif
  if l:out ==# l:in | return | endif

  let l:view = winsaveview()
  call setline(1, l:out)
  if len(l:out) < line('$')
    silent execute (len(l:out) + 1) . ',$delete _'
  endif
  call winrestview(l:view)
endfunction

" Quita espacios al final de línea sin mover el cursor
function! my#fmt#trim() abort
  if &filetype =~# '^\%(markdown\|diff\|gitcommit\)$' || !&modifiable | return | endif
  let l:view = winsaveview()
  keeppatterns silent! %s/\s\+$//e
  call winrestview(l:view)
endfunction

function! my#fmt#on_save() abort
  if get(g:, 'my_trim_on_save', 1) | call my#fmt#trim() | endif
  if get(g:, 'my_format_on_save', 0) && !get(b:, 'my_no_format') | call my#fmt#buffer(1) | endif
endfunction

function! my#fmt#toggle_on_save() abort
  let g:my_format_on_save = !get(g:, 'my_format_on_save', 0)
  echo 'Formatear al guardar: ' . (g:my_format_on_save ? 'activado' : 'desactivado')
endfunction
