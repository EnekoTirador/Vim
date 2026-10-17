" ── config/autocmds.vim ── comportamientos automáticos ────────────────────────
augroup MyAutocmds
  autocmd!
  " Volver a la última posición al reabrir un archivo
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line('$') && &filetype !~# 'commit\|rebase'
        \ | execute 'normal! g`"' | endif

  " Números relativos solo mientras NO escribes (en insertar vuelven los absolutos)
  autocmd InsertEnter * let b:my_rnu = &l:relativenumber | setlocal norelativenumber
  autocmd InsertLeave * if get(b:, 'my_rnu') | setlocal relativenumber | endif

  " Línea del cursor solo en la ventana activa
  autocmd WinEnter,BufEnter * if &buftype ==# '' | setlocal cursorline | endif
  autocmd WinLeave * if &buftype ==# '' | setlocal nocursorline | endif

  " Terminales y ayudas: sin adornos
  autocmd TerminalOpen * setlocal nonumber norelativenumber nolist signcolumn=no nocursorline
  autocmd FileType help,man,qf,fugitive,git setlocal nolist

  " <o> en un comentario no debe continuar el comentario
  autocmd FileType * setlocal formatoptions-=o

  " Guías de indentación (se ajustan al shiftwidth de cada archivo)
  autocmd BufWinEnter,FileType * call my#ui#indent_guides()
  autocmd OptionSet shiftwidth,tabstop call my#ui#indent_guides()

  " Barra de buffers solo si hay más de uno
  autocmd BufAdd,BufDelete,BufEnter,BufWipeout * call my#ui#tabline_visibility()

  " Recargar archivos cambiados fuera de Vim (git checkout, formateadores...)
  autocmd FocusGained,BufEnter,CursorHold * if mode() !=# 'c' && &buftype ==# '' | silent! checktime | endif

  " Entorno virtual para la statusline
  autocmd FileType python call my#lang#detect_venv()

  " Limpiar espacios y (opcional) formatear al guardar
  autocmd BufWritePre * call my#fmt#on_save()

  " Destello al copiar (yank)
  autocmd TextYankPost * call s:flash()

  " Reajustar splits al cambiar el tamaño de la terminal
  autocmd VimResized * wincmd =

  " Devolver el cursor de la terminal a su forma normal al salir
  autocmd VimLeave * if exists('*echoraw') | silent! call echoraw("\<Esc>[0 q") | endif
augroup END

function! s:flash() abort
  if v:event.operator !=# 'y' || v:event.regtype ==# '' | return | endif
  let l:s = getpos("'[") | let l:e = getpos("']")
  let l:pos = []
  for l:ln in range(l:s[1], min([l:e[1], l:s[1] + 80]))
    if v:event.regtype ==# 'V'
      call add(l:pos, l:ln)
    else
      let l:from = l:ln == l:s[1] ? l:s[2] : 1
      let l:to = l:ln == l:e[1] ? l:e[2] : max([strlen(getline(l:ln)), 1])
      call add(l:pos, [l:ln, l:from, max([l:to - l:from + 1, 1])])
    endif
  endfor
  let l:win = win_getid()
  let l:ids = []
  for l:i in range(0, len(l:pos) - 1, 8)                 " matchaddpos admite 8 a la vez
    call add(l:ids, matchaddpos('IncSearch', l:pos[l:i : l:i + 7], 10, -1, {'window': l:win}))
  endfor
  call timer_start(160, {-> map(l:ids, 'matchdelete(v:val, l:win)')})
endfunction
