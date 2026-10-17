" ── autoload/my/run.vim ── ejecutar el archivo actual y REPL ───────────────────
scriptencoding utf-8

function! s:warn(msg) abort
  echohl WarningMsg | echo a:msg | echohl None
endfunction

" Ejecuta el archivo actual en el terminal flotante 'main'.
" El comando sale del registro (config/languages.vim); b:run_cmd lo sobreescribe.
function! my#run#file(...) abort
  if &buftype !=# '' || empty(expand('%'))
    return s:warn('Abre o guarda un archivo antes de ejecutarlo')
  endif
  silent! update
  let l:cmd = my#lang#run_cmd()
  if empty(l:cmd)
    return s:warn('No sé ejecutar "' . &filetype . '": añádelo a g:my_langs (config/languages.vim) o pon b:run_cmd')
  endif
  if a:0 && !empty(a:1) | let l:cmd .= ' ' . a:1 | endif
  let g:my_last_run = {'cmd': l:cmd, 'root': my#lang#root(), 'title': 'Run · ' . expand('%:t')}
  call s:exec(g:my_last_run)
endfunction

function! s:exec(r) abort
  " Una sola línea: entra en la raíz, limpia la pantalla, imprime el comando en
  " gris y lo ejecuta. (printf con códigos ANSI y no `clear`: funciona en cualquier shell)
  " (comillas simples: el \033 debe llegar LITERAL al printf del shell, no como un ESC real)
  let l:hdr = '\033[H\033[2J\033[2m❯ %s\033[0m\n'
  let l:line = 'cd ' . shellescape(a:r.root) . ' && printf ' . shellescape(l:hdr)
        \ . ' ' . shellescape(a:r.cmd) . ' && ' . a:r.cmd
  call my#float#send('main', l:line . "\r", {'title': a:r.title, 'cwd': a:r.root, 'clear': 1})
endfunction

function! my#run#ask() abort
  let l:args = input('Argumentos: ')
  call my#run#file(l:args)
endfunction

function! my#run#last() abort
  if exists('g:my_last_run') | call s:exec(g:my_last_run) | else | call my#run#file() | endif
endfunction

" ── REPL ─────────────────────────────────────────────────────────────────────
function! s:repl() abort
  for l:r in get(my#lang#get(&filetype), 'repl', [])
    if executable(my#lang#bin(l:r.cmd)) | return l:r | endif
  endfor
  return {}
endfunction

function! s:repl_opts(r) abort
  return {'cmd': my#lang#expand(a:r.cmd), 'cwd': my#lang#root(), 'title': 'REPL · ' . my#lang#bin(a:r.cmd)}
endfunction

function! my#run#repl() abort
  let l:r = s:repl()
  if empty(l:r) | return s:warn('No hay REPL para "' . &filetype . '" (mira :Doctor)') | endif
  call my#float#toggle('repl', s:repl_opts(l:r))
endfunction

" Envía las líneas [a, b] al REPL (quitando la indentación común)
function! my#run#send(first, last) abort
  let l:r = s:repl()
  if empty(l:r) | return s:warn('No hay REPL para "' . &filetype . '" (mira :Doctor)') | endif
  let l:lines = getline(a:first, a:last)
  let l:min = min(map(filter(copy(l:lines), 'v:val =~# "\\S"'), 'len(matchstr(v:val, "^\\s*"))'))
  let l:lines = map(l:lines, {_, l -> l =~# '\S' ? strpart(l, l:min) : ''})
  let l:text = join(l:lines, "\n")
  if get(l:r, 'paste')
    " pegado seguro: el REPL recibe el bloque entero sin autoindentar
    let l:payload = "\<Esc>[200~" . l:text . "\<Esc>[201~" . "\r"
  else
    let l:payload = substitute(l:text, "\n", "\r", 'g') . "\r"
  endif
  " Un bloque que termina indentado necesita una línea en blanco para cerrarse
  if len(l:lines) > 1 && l:lines[-1] =~# '^\s' || l:lines[-1] =~# ':\s*$' | let l:payload .= "\r" | endif
  call my#float#send('repl', l:payload, s:repl_opts(l:r))
endfunction

" ── Terminales concretos ─────────────────────────────────────────────────────
" Terminal general, en la raíz del proyecto actual
function! my#run#terminal() abort
  call my#float#toggle('main', {'cwd': my#lang#root(), 'title': 'Terminal'})
endfunction

function! my#run#lazygit() abort
  call my#float#toggle('lazygit', {'cmd': 'lazygit', 'cwd': my#lang#root(), 'title': 'lazygit', 'width': 0.95, 'height': 0.92})
endfunction
