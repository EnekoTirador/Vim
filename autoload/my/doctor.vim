" ── autoload/my/doctor.vim ── :Doctor, ¿qué me falta en esta máquina? ─────────
" Todo se deduce del registro g:my_langs y g:my_tools: al añadir un lenguaje
" o una herramienta, el doctor la comprueba sin tocar este archivo.
scriptencoding utf-8

function! s:mark(ok) abort
  return a:ok ? '✔' : '✘'
endfunction

" Ruta de una herramienta: en el PATH, o (fzf) el binario que bajó el plugin
function! s:where(tool) abort
  let l:p = exepath(a:tool)
  if empty(l:p) && a:tool ==# 'fzf' && exists('g:plugs') && has_key(g:plugs, 'fzf')
    let l:p = substitute(g:plugs.fzf.dir, '/\+$', '', '') . '/bin/fzf'
    if !executable(l:p) | let l:p = '' | endif
  endif
  return l:p
endfunction

function! s:alts(cmds) abort
  return join(map(copy(a:cmds), {_, c -> s:mark(executable(my#lang#bin(c))) . ' ' . my#lang#bin(c)}), '  ·  ')
endfunction

function! my#doctor#lines() abort
  let l:v = v:versionlong
  let l:out = []
  call add(l:out, printf('  Vim %d.%d.%d    terminal %s   popup %s   clipboard %s   python3 %s',
        \ l:v / 1000000, (l:v / 10000) % 100, l:v % 10000,
        \ s:mark(has('terminal')), s:mark(has('popupwin')), s:mark(has('clipboard')), s:mark(has('python3'))))
  call add(l:out, '  Config: ' . g:my_root)
  if exists('g:plugs')
    let l:miss = filter(copy(g:plugs), '!isdirectory(v:val.dir)')
    call add(l:out, printf('  Plugins: %d declarados, %s', len(g:plugs),
          \ empty(l:miss) ? 'todos instalados ✔' : '✘ faltan ' . join(keys(l:miss), ', ') . '  (:PlugInstall)'))
  endif
  call add(l:out, '')
  call add(l:out, ' Herramientas')
  for [l:t, l:why] in items(g:my_tools)
    let l:path = s:where(l:t)
    call add(l:out, printf('  %s %-9s %s%s', s:mark(!empty(l:path)), l:t, l:why, empty(l:path) ? '' : '   ' . l:path))
  endfor
  for l:ft in sort(keys(g:my_langs))
    let l:lang = g:my_langs[l:ft]
    call add(l:out, '')
    call add(l:out, ' ' . l:ft)
    let l:run = get(l:lang, 'run', '')
    let l:runs = type(l:run) == v:t_list ? map(copy(l:run), 'v:val[1]') : (empty(l:run) ? [] : [l:run])
    if !empty(l:runs)  | call add(l:out, '  ejecutar    ' . s:alts(l:runs[-1:])) | endif
    if has_key(l:lang, 'fmt')  | call add(l:out, '  formatear   ' . s:alts(l:lang.fmt)) | endif
    if has_key(l:lang, 'lsp')
      for l:group in l:lang.lsp
        call add(l:out, '  LSP         ' . join(map(copy(l:group), {_, s -> s:mark(executable(s.cmd[0])) . ' ' . s.cmd[0]}), '  ·  '))
      endfor
    endif
    if has_key(l:lang, 'repl') | call add(l:out, '  REPL        ' . s:alts(map(copy(l:lang.repl), 'v:val.cmd'))) | endif
  endfor
  call add(l:out, '')
  call add(l:out, ' Falta algo en NixOS sin tocar tu configuración →  ' . g:my_root . '/bin/vimx')
  call add(l:out, '                                                  (q para cerrar)')
  return l:out
endfunction

function! s:filter(id, key) abort
  if a:key ==# 'q' || a:key ==# "\<Esc>" || a:key ==# "\<CR>"
    call popup_close(a:id) | return 1
  elseif a:key ==# 'j' || a:key ==# "\<Down>"
    call popup_setoptions(a:id, {'firstline': popup_getoptions(a:id).firstline + 1}) | return 1
  elseif a:key ==# 'k' || a:key ==# "\<Up>"
    call popup_setoptions(a:id, {'firstline': max([1, popup_getoptions(a:id).firstline - 1])}) | return 1
  endif
  return 1                               " modal: se traga el resto de teclas
endfunction

function! my#doctor#show() abort
  let l:lines = my#doctor#lines()
  let l:id = popup_create(l:lines, {
        \ 'pos': 'center', 'minwidth': 70, 'maxwidth': &columns - 6, 'maxheight': &lines - 6,
        \ 'border': [1, 1, 1, 1], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ 'borderhighlight': ['MyFloatBorder'], 'highlight': 'MyFloat', 'padding': [0, 1, 0, 1],
        \ 'title': ' ' . my#ui#icon('doctor') . ' Doctor ', 'filter': function('s:filter'), 'zindex': 300,
        \ 'scrollbar': 1,
        \ })
  call win_execute(l:id, 'syntax match MyTitle /^ \S.*/')
  call win_execute(l:id, 'syntax match MyOk /✔/')
  call win_execute(l:id, 'syntax match MyMiss /✘/')
  call win_execute(l:id, 'syntax match MyDim /\s\{3}\/\S*$/')
endfunction

" Versión en texto plano para scripts (install.sh): vim -es -c 'call my#doctor#print()'
function! my#doctor#print() abort
  call writefile(my#doctor#lines(), '/dev/stdout')
endfunction
