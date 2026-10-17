" ── autoload/my/float.vim ── terminales flotantes con nombre ───────────────────
"
" Un "terminal flotante" es un terminal de Vim dentro de un popup. Cada uno
" tiene un NOMBRE ('main', 'repl', 'lazygit'...). Se crea la primera vez, y al
" ocultarlo NO se mata: conserva su shell, su historial y su pantalla.
"
"   my#float#toggle(nombre, cmd [, opts])  mostrar / ocultar
"   my#float#send(nombre, texto [, opts])  escribir en él (lo abre si hace falta)
"   my#float#hide_all()                    ocultar los visibles
"   my#float#kill(nombre)                  matar el proceso y cerrarlo
"
" opts: cmd (qué lanzar; '' = tu shell), cwd, title, width, height (0-1), clear
scriptencoding utf-8

let s:terms = {}                         " nombre → {'buf': n, 'win': n}

function! s:alive(name) abort
  return has_key(s:terms, a:name) && bufexists(s:terms[a:name].buf)
        \ && term_getstatus(s:terms[a:name].buf) =~# 'running'
endfunction

function! s:visible(name) abort
  return has_key(s:terms, a:name) && s:terms[a:name].win > 0
        \ && !empty(popup_getpos(s:terms[a:name].win))
endfunction

" Tamaño y posición centrados. Los ratios se pueden fijar con g:my_float.
function! s:geometry(o) abort
  let l:c = extend({'width': 0.88, 'height': 0.80}, get(g:, 'my_float', {}))
  let l:ow = max([40, float2nr(&columns * get(a:o, 'width', l:c.width))])
  let l:oh = max([10, float2nr((&lines - &cmdheight) * get(a:o, 'height', l:c.height))])
  " Texto útil = tamaño total menos borde (2) y padding horizontal (2)
  return {
        \ 'minwidth': l:ow - 4, 'maxwidth': l:ow - 4,
        \ 'minheight': l:oh - 2, 'maxheight': l:oh - 2,
        \ 'line': max([1, (&lines - &cmdheight - l:oh) / 2 + 1]),
        \ 'col': max([1, (&columns - l:ow) / 2 + 1]),
        \ }
endfunction

function! s:title(name, o) abort
  return ' ' . my#ui#icon('term') . ' ' . get(a:o, 'title', a:name) . ' '
endfunction

function! s:start(name, o) abort
  let l:g = s:geometry(a:o)
  let l:cmd = get(a:o, 'cmd', '')
  let l:cwd = get(a:o, 'cwd', getcwd())
  let l:buf = term_start(empty(l:cmd) ? [empty($SHELL) ? &shell : $SHELL] : l:cmd, {
        \ 'hidden': 1, 'norestore': 1, 'term_finish': 'close', 'term_kill': 'term',
        \ 'term_rows': l:g.minheight, 'term_cols': l:g.minwidth,
        \ 'cwd': isdirectory(l:cwd) ? l:cwd : getcwd(),
        \ 'env': {'COLORTERM': 'truecolor', 'VIM_FLOAT': a:name},
        \ })
  if l:buf == 0
    throw 'No se pudo abrir el terminal'
  endif
  let s:terms[a:name] = {'buf': l:buf, 'win': 0}
endfunction

function! s:on_close(name, id, result) abort
  if has_key(s:terms, a:name) && s:terms[a:name].win == a:id
    let s:terms[a:name].win = 0
  endif
endfunction

function! s:show(name, o) abort
  let l:opts = extend(s:geometry(a:o), {
        \ 'border': [1, 1, 1, 1], 'padding': [0, 1, 0, 1],
        \ 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ 'borderhighlight': ['MyFloatBorder'], 'highlight': 'MyFloat',
        \ 'title': s:title(a:name, a:o), 'zindex': 200,
        \ 'callback': function('s:on_close', [a:name]),
        \ })
  " Un terminal en popup recibe el foco solo (no hace falta win_gotoid; de hecho
  " Vim lo prohíbe: E863). Y solo puede haber UNO a la vez (E861).
  let l:was_normal = term_getstatus(s:terms[a:name].buf) =~# 'normal'
  let s:terms[a:name].win = popup_create(s:terms[a:name].buf, l:opts)
  " Mapeo solo para NUESTROS terminales (no afecta a fzf ni a otros): Esc Esc → modo Normal
  call win_execute(s:terms[a:name].win, 'tnoremap <buffer> <silent> <Esc><Esc> <C-\><C-n>')
  " Si lo ocultamos estando en modo Normal del terminal (Esc Esc), al volver
  " hay que seguir escribiendo en el shell, no lanzando comandos de Vim
  if l:was_normal | call feedkeys('i', 'n') | endif
endfunction

" Abre (o trae al frente) el terminal; no lo oculta nunca.
function! my#float#open(name, ...) abort
  let l:o = a:0 ? a:1 : {}
  if !s:alive(a:name) | call s:start(a:name, l:o) | endif
  if s:visible(a:name)
    if has_key(l:o, 'title') | call popup_setoptions(s:terms[a:name].win, {'title': s:title(a:name, l:o)}) | endif
    return
  endif
  call my#float#hide_all()
  call s:show(a:name, l:o)
endfunction

function! my#float#hide(name) abort
  if s:visible(a:name) | call popup_close(s:terms[a:name].win) | endif
endfunction

function! my#float#hide_all() abort
  for l:n in keys(s:terms) | call my#float#hide(l:n) | endfor
endfunction

" Mostrar si está oculto; ocultar si está visible (siempre tiene el foco)
function! my#float#toggle(name, ...) abort
  if s:visible(a:name)
    call my#float#hide(a:name)
  else
    call my#float#open(a:name, a:0 ? a:1 : {})
  endif
endfunction

" Escribe texto tal cual en el terminal (con \r para dar Enter).
" Si es nuevo, espera un instante a que el shell arranque.
function! my#float#send(name, text, ...) abort
  let l:o = a:0 ? a:1 : {}
  let l:fresh = !s:alive(a:name)
  call my#float#open(a:name, l:o)
  let l:payload = (get(l:o, 'clear') ? "\<C-u>\<C-l>" : '') . a:text
  let l:buf = s:terms[a:name].buf
  if l:fresh
    call timer_start(150, {-> term_sendkeys(l:buf, l:payload)})
  else
    call term_sendkeys(l:buf, l:payload)
  endif
endfunction

function! my#float#kill(name) abort
  if !has_key(s:terms, a:name) | return | endif
  call my#float#hide(a:name)
  if bufexists(s:terms[a:name].buf) | silent! execute 'bwipeout!' s:terms[a:name].buf | endif
  call remove(s:terms, a:name)
endfunction

function! my#float#kill_all() abort
  for l:n in keys(s:terms) | call my#float#kill(l:n) | endfor
endfunction

" Al redimensionar Vim, recoloca los visibles
function! my#float#reposition() abort
  for [l:n, l:t] in items(s:terms)
    if s:visible(l:n) | call popup_setoptions(l:t.win, s:geometry({})) | endif
  endfor
endfunction
