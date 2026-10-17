" ── autoload/my/lang.vim ── lee el registro g:my_langs ─────────────────────────
scriptencoding utf-8

function! my#lang#get(ft) abort
  return get(g:my_langs, a:ft, {})
endfunction

" El binario de un comando: su primera palabra, ignorando `env` y VAR=valor delante
function! my#lang#bin(cmd) abort
  let l:c = substitute(a:cmd, '^\s*\%(env\s\+\)\?\%(\w\+=\S*\s\+\)*', '', '')
  let l:b = matchstr(l:c, '^\S\+')
  return l:b ==# '{python}' ? 'python3' : l:b
endfunction

" De una lista de alternativas, la primera cuyo binario esté instalado ('' si ninguna)
function! my#lang#pick(cmds) abort
  for l:c in a:cmds
    if executable(my#lang#bin(l:c)) | return l:c | endif
  endfor
  return ''
endfunction

" Raíz del proyecto: el marcador más cercano al archivo (o su carpeta si no hay)
function! my#lang#root(...) abort
  let l:start = a:0 ? a:1 : expand('%:p:h')
  if empty(l:start) || !isdirectory(l:start) | let l:start = getcwd() | endif
  let l:best = ''
  for l:m in g:my_root_markers
    let l:d = finddir(l:m, l:start . ';')
    let l:f = findfile(l:m, l:start . ';')
    let l:cands = []
    if !empty(l:d) | call add(l:cands, fnamemodify(l:d, ':p:h:h')) | endif
    if !empty(l:f) | call add(l:cands, fnamemodify(l:f, ':p:h')) | endif
    for l:c in l:cands
      if len(l:c) > len(l:best) | let l:best = l:c | endif
    endfor
  endfor
  return empty(l:best) ? l:start : l:best
endfunction

" Python del proyecto: .venv/venv, el entorno activo, o python3
function! my#lang#python(root) abort
  let l:try = [a:root . '/.venv/bin/python', a:root . '/venv/bin/python']
  if !empty($VIRTUAL_ENV) | call add(l:try, $VIRTUAL_ENV . '/bin/python') | endif
  for l:p in l:try
    if executable(l:p) | return l:p | endif
  endfor
  return executable('python3') ? 'python3' : 'python'
endfunction

" Nombre del entorno virtual (para la statusline); se cachea en b:my_venv
function! my#lang#detect_venv() abort
  let l:root = my#lang#root()
  let l:py = my#lang#python(l:root)
  let b:my_venv = l:py =~# '/' ? fnamemodify(fnamemodify(l:py, ':h:h'), ':t') : ''
endfunction

" Escapa para el shell solo si hace falta (así los comandos quedan legibles)
function! s:q(str) abort
  return a:str =~# '^[A-Za-z0-9_./:@%+=-]\+$' ? a:str : shellescape(a:str)
endfunction

" Sustituye {file} {dir} {name} {root} {python} {sw} en un comando.
" Con {'rel': 1}, {file} sale relativo a la raíz del proyecto (más legible al ejecutar).
function! my#lang#expand(cmd, ...) abort
  let s:rel = a:0 && get(a:1, 'rel')
  return substitute(a:cmd, '{\(\w\+\)}', '\=s:placeholder(submatch(1), submatch(0))', 'g')
endfunction

function! s:placeholder(key, original) abort
  if a:key ==# 'file'
    let l:f = expand('%:p')
    if s:rel
      let l:root = my#lang#root()
      if stridx(l:f, l:root . '/') == 0 | let l:f = strpart(l:f, len(l:root) + 1) | endif
    endif
    return s:q(l:f)
  elseif a:key ==# 'dir'    | return s:q(expand('%:p:h'))
  elseif a:key ==# 'name'   | return s:q(expand('%:t:r'))
  elseif a:key ==# 'root'   | return s:q(my#lang#root())
  elseif a:key ==# 'python' | return s:q(my#lang#python(my#lang#root()))
  elseif a:key ==# 'sw'     | return string(shiftwidth())
  endif
  return a:original
endfunction

" Ejecutar el archivo tal cual (usa su shebang): ./script.sh
function! s:direct(opts) abort
  let l:f = my#lang#expand('{file}', a:opts)
  return l:f =~# '/' ? l:f : './' . l:f
endfunction

" Comando para ejecutar el archivo actual ('' si no sabemos cómo)
function! my#lang#run_cmd() abort
  let l:o = {'rel': 1}
  if exists('b:run_cmd') | return my#lang#expand(b:run_cmd, l:o) | endif
  let l:lang = my#lang#get(&filetype)
  let l:file = expand('%:p')
  let l:shebang = getline(1) =~# '^#!' && executable(l:file)

  if get(l:lang, 'shebang') && l:shebang
    return s:direct(l:o)
  endif
  let l:run = get(l:lang, 'run', '')
  if type(l:run) == v:t_list
    for [l:pat, l:cmd] in l:run
      if empty(l:pat) || l:file =~# l:pat | return my#lang#expand(l:cmd, l:o) | endif
    endfor
    return ''
  elseif !empty(l:run)
    return my#lang#expand(l:run, l:o)
  endif
  return l:shebang ? s:direct(l:o) : ''
endfunction
