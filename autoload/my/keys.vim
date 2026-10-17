" ── autoload/my/keys.vim ── registro de atajos, which-key y buscador ──────────
scriptencoding utf-8

if !exists('g:my_keys') | let g:my_keys = [] | endif

" my#keys#map({modos}, {lhs}, {rhs}, {desc} [, {opts}])
"   Define el atajo (noremap + silent) y lo apunta en el registro.
"   opts: buffer (local al buffer), expr, hide (no mostrar en :Keys)
function! my#keys#map(modes, lhs, rhs, desc, ...) abort
  let l:o = a:0 ? a:1 : {}
  let l:flags = '<silent>' . (get(l:o, 'buffer') ? '<buffer>' : '') . (get(l:o, 'expr') ? '<expr>' : '')
  for l:m in split(a:modes, '\zs')
    execute l:m . 'noremap' l:flags a:lhs a:rhs
  endfor
  " Si se vuelve a definir (recarga de config), sustituye la entrada anterior
  call filter(g:my_keys, {_, e -> !(e.lhs ==# a:lhs && e.modes ==# a:modes && e.buf == (get(l:o, 'buffer') ? bufnr('%') : 0))})
  call add(g:my_keys, {
        \ 'modes': a:modes, 'lhs': a:lhs, 'desc': a:desc,
        \ 'buf': get(l:o, 'buffer') ? bufnr('%') : 0, 'hide': get(l:o, 'hide', 0)})
endfunction

" ── Utilidades de teclas ─────────────────────────────────────────────────────

" '<leader>ff' → ['f','f'];  '<leader><Space>' → [' ']   (solo lo que va tras <leader>)
function! s:tokens(lhs) abort
  let l:rest = substitute(a:lhs, '\c^<leader>', '', '')
  let l:out = []
  while !empty(l:rest)
    let l:t = matchstr(l:rest, '^\%(<[^>]\+>\|.\)')
    call add(l:out, (l:t ==? '<space>' || l:t ==? '<leader>') ? get(g:, 'mapleader', ' ') : l:t)
    let l:rest = strpart(l:rest, len(l:t))
  endwhile
  return l:out
endfunction

function! s:label(key) abort
  return a:key ==# ' ' ? 'SPC' : a:key
endfunction

" '<C-p>' → "\<C-p>" evaluado como tecla real (para feedkeys)
function! s:feedable(lhs) abort
  let l:s = substitute(a:lhs, '\c<leader>', escape(get(g:, 'mapleader', ' '), '\'), 'g')
  return substitute(l:s, '<[^<>]\+>', '\=eval(''"\'' . submatch(0) . ''"'')', 'g')
endfunction

" Entradas de modo normal que cuelgan de <leader>, visibles desde este buffer
function! s:leader_entries() abort
  return filter(copy(g:my_keys), {_, e ->
        \ e.modes =~# 'n' && e.lhs =~? '^<leader>' && (e.buf == 0 || e.buf == bufnr('%'))})
endfunction

" ── Mini which-key ───────────────────────────────────────────────────────────
" Se invoca cuando pulsas <Space> y dejas de teclear. Muestra qué hay debajo del
" prefijo actual, lee la siguiente tecla y, al llegar a una hoja, la ejecuta.
function! my#keys#hint() abort
  let l:entries = s:leader_entries()
  let l:seq = []        " teclas pulsadas tras <leader> (normalizadas)
  let l:typed = ''      " lo mismo, en crudo, para reenviarlo a feedkeys()
  let l:popup = 0

  while 1
    " Qué cuelga del prefijo actual: tecla → {label, group}
    let l:next = {}
    for l:e in l:entries
      let l:t = s:tokens(l:e.lhs)
      let l:n = len(l:seq)
      " (cuidado: l:t[0 : -1] en Vim es la lista ENTERA, por eso el l:n > 0)
      if len(l:t) <= l:n || (l:n > 0 && l:t[0 : l:n - 1] !=# l:seq)
        continue
      endif
      let l:k = l:t[len(l:seq)]
      if len(l:t) == len(l:seq) + 1
        let l:next[l:k] = {'label': l:e.desc, 'group': 0}
      else
        let l:gk = join(l:seq + [l:k], '')
        let l:next[l:k] = {'label': '+' . get(g:my_key_groups, l:gk, 'más'), 'group': 1}
      endif
    endfor

    if empty(l:next)
      echohl WarningMsg | echo 'Sin atajo: <leader>' . join(map(copy(l:seq), 's:label(v:val)'), '') | echohl None
      return
    endif

    let l:popup = s:hint_popup(l:next, l:seq)
    redraw
    let l:c = getcharstr()
    call popup_close(l:popup)
    let l:popup = 0
    redraw

    if l:c ==# "\<Esc>" || l:c ==# "\<C-c>"
      return
    elseif l:c ==# "\<BS>"
      if empty(l:seq) | return | endif
      call remove(l:seq, -1)
      let l:typed = strcharpart(l:typed, 0, strchars(l:typed) - 1)
      continue
    endif

    call add(l:seq, l:c)
    let l:typed .= l:c
    if has_key(l:next, l:c) && !l:next[l:c].group
      " Hoja: reenviamos la secuencia completa y Vim ejecuta el mapeo real
      call feedkeys(get(g:, 'mapleader', ' ') . l:typed, 'm')
      return
    elseif !has_key(l:next, l:c)
      echohl WarningMsg | echo 'Sin atajo: <leader>' . join(map(copy(l:seq), 's:label(v:val)'), '') | echohl None
      return
    endif
  endwhile
endfunction

function! s:hint_popup(next, seq) abort
  " Grupos primero, luego hojas; cada bloque ordenado alfabéticamente
  let l:sorted = sort(keys(a:next))
  let l:keys = filter(copy(l:sorted), {_, k -> a:next[k].group}) + filter(copy(l:sorted), {_, k -> !a:next[k].group})
  let l:cells = map(copy(l:keys), {_, k -> printf('%-3s → %s', s:label(k), a:next[k].label)})
  let l:w = max(map(copy(l:cells), 'strdisplaywidth(v:val)')) + 3
  let l:cols = max([1, (&columns - 8) / l:w])
  let l:lines = []
  let l:i = 0
  while l:i < len(l:cells)
    let l:row = ''
    for l:c in l:cells[l:i : l:i + l:cols - 1]
      let l:row .= l:c . repeat(' ', l:w - strdisplaywidth(l:c))
    endfor
    call add(l:lines, substitute(l:row, '\s\+$', '', ''))
    let l:i += l:cols
  endwhile
  let l:title = ' <leader>' . join(map(copy(a:seq), 's:label(v:val)'), ' ')
  if !empty(a:seq)
    let l:title .= '  ·  ' . get(g:my_key_groups, join(a:seq, ''), '')
  endif
  let l:id = popup_create(l:lines, {
        \ 'pos': 'botleft', 'line': &lines - &cmdheight, 'col': 2,
        \ 'minwidth': &columns - 4, 'maxwidth': &columns - 4,
        \ 'border': [1, 1, 1, 1], 'borderchars': ['─', '│', '─', '│', '╭', '╮', '╯', '╰'],
        \ 'borderhighlight': ['MyHintBorder'], 'highlight': 'MyHint',
        \ 'padding': [0, 1, 0, 1], 'title': l:title . ' ', 'zindex': 300,
        \ })
  call win_execute(l:id, 'syntax match MyHintKey /\S\+\ze\s\+→/')
  call win_execute(l:id, 'syntax match MyHintArrow /→/')
  call win_execute(l:id, 'syntax match MyHintGroup /+\S.\{-}\ze\%(\s\{2,}\|$\)/')
  return l:id
endfunction

" ── Buscador de atajos (:Keys / <leader>?) ───────────────────────────────────
function! my#keys#search() abort
  let l:rows = []
  let l:i = 0
  for l:e in g:my_keys
    if !l:e.hide && (l:e.buf == 0 || l:e.buf == bufnr('%'))
      let l:grp = ''
      if l:e.lhs =~? '^<leader>.'
        let l:grp = get(g:my_key_groups, matchstr(substitute(l:e.lhs, '\c^<leader>', '', ''), '^.'), '')
      endif
      call add(l:rows, printf("%d\t%-3s\t%-16s\t%-16s\t%s", l:i, l:e.modes, substitute(l:e.lhs, '\c<leader>', 'SPC ', ''), l:grp, l:e.desc))
    endif
    let l:i += 1
  endfor
  if exists('*fzf#run')
    call fzf#run(fzf#wrap({
          \ 'source': l:rows, 'sink': function('s:run_entry'),
          \ 'options': ['--prompt', 'Atajos> ', '--delimiter', "\t", '--with-nth', '2..', '--tabstop', '4', '--no-sort', '--layout=reverse'],
          \ }))
  else
    echo join(map(l:rows, 'substitute(v:val, "^\\d\\+\t", "", "")'), "\n")
  endif
endfunction

function! s:run_entry(line) abort
  let l:e = get(g:my_keys, str2nr(split(a:line, "\t")[0]), {})
  if empty(l:e) | return | endif
  if l:e.modes =~# 'n'
    call feedkeys(s:feedable(l:e.lhs), 'm')
  else
    echo 'Atajo de modo "' . l:e.modes . '": ' . l:e.lhs
  endif
endfunction
