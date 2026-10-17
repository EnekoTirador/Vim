" ── autoload/my/ui.vim ── tema, statusline, bufferline y pequeños helpers ─────
scriptencoding utf-8

" ── Iconos (Nerd Font si g:my_nerdfont=1; si no, ASCII/Unicode básico) ────────
let s:nerd = {
  \ 'branch': 0xe0a0, 'lock': 0xf023, 'term': 0xf120, 'err': 0xf057, 'warn': 0xf071,
  \ 'info': 0xf05a, 'hint': 0xf0eb, 'capl': 0xe0b6, 'capr': 0xe0b4, 'file': 0xf15b,
  \ 'python': 0xe606, 'sh': 0xe795, 'nix': 0xf313, 'vim': 0xe62b, 'markdown': 0xe73e,
  \ 'json': 0xe60b, 'yaml': 0xe6a8, 'toml': 0xe6b2, 'lua': 0xe620, 'gitcommit': 0xe702,
  \ 'keys': 0xf11c, 'doctor': 0xf0f1,
  \ }
let s:plain = {
  \ 'branch': 'git:', 'lock': 'RO', 'term': '>_', 'err': 'E', 'warn': 'W', 'info': 'I',
  \ 'hint': 'H', 'capl': '', 'capr': '', 'file': '', 'keys': '', 'doctor': '',
  \ }

function! my#ui#icon(name) abort
  if get(g:, 'my_nerdfont', 1)
    return has_key(s:nerd, a:name) ? nr2char(s:nerd[a:name]) : ''
  endif
  return get(s:plain, a:name, '')
endfunction

" ── Tema ─────────────────────────────────────────────────────────────────────
function! my#ui#colorscheme(flavor) abort
  let g:my_flavor = a:flavor
  try
    execute 'colorscheme catppuccin_' . a:flavor
  catch
    " El plugin del tema aún no está instalado (primer arranque): tema de Vim
    silent! colorscheme habamax
    call my#ui#highlights()
  endtry
endfunction

function! my#ui#cycle_flavor() abort
  let l:i = (index(g:my_flavors, g:my_flavor) + 1) % len(g:my_flavors)
  call my#ui#colorscheme(g:my_flavors[l:i])
  redraw | echo 'Tema: catppuccin ' . g:my_flavors[l:i]
endfunction

function! my#ui#toggle_transparent() abort
  let g:my_transparent = !get(g:, 'my_transparent', 0)
  call my#ui#colorscheme(g:my_flavor)
endfunction

function! my#ui#reload() abort
  unlet! g:loaded_my_config
  let g:my_keys = []
  execute 'source' fnameescape(g:my_root . '/vimrc')
  redraw | echo 'Config recargada'
endfunction

" ── Resaltados propios (se recalculan al cambiar de tema) ────────────────────
function! s:hi(group, fg, bg, ...) abort
  execute printf('highlight %s guifg=%s guibg=%s gui=%s cterm=%s', a:group,
        \ empty(a:fg) ? 'NONE' : a:fg, empty(a:bg) ? 'NONE' : a:bg,
        \ a:0 ? a:1 : 'NONE', a:0 ? a:1 : 'NONE')
endfunction

function! my#ui#highlights() abort
  let p = my#palette#get()
  " Panel flotante: terminal, which-key, doctor
  call s:hi('MyFloat', p.text, p.mantle)
  call s:hi('MyFloatBorder', p.blue, p.mantle)
  call s:hi('Terminal', p.text, p.mantle)
  call s:hi('MyHint', p.text, p.mantle)
  call s:hi('MyHintBorder', p.mauve, p.mantle)
  call s:hi('MyHintKey', p.peach, p.mantle, 'bold')
  call s:hi('MyHintArrow', p.overlay0, p.mantle)
  call s:hi('MyHintGroup', p.mauve, p.mantle, 'bold')
  call s:hi('MyOk', p.green, p.mantle, 'bold')
  call s:hi('MyMiss', p.red, p.mantle, 'bold')
  call s:hi('MyDim', p.overlay1, p.mantle)
  call s:hi('MyTitle', p.mauve, p.mantle, 'bold')
  " Guías de indentación y caracteres invisibles: muy sutiles
  call s:hi('SpecialKey', p.surface1, '')
  call s:hi('Whitespace', p.surface1, '')
  call s:hi('CursorLineNr', p.lavender, '', 'bold')
  " Barras de git (vim-signify)
  call s:hi('SignifySignAdd', p.green, '')
  call s:hi('SignifySignChange', p.yellow, '')
  call s:hi('SignifySignDelete', p.red, '')
  " Statusline y bufferline: un grupo por modo para el color de la "píldora"
  call s:hi('StatusLine', p.overlay1, p.mantle)
  call s:hi('StatusLineNC', p.overlay0, p.mantle)
  call s:hi('MyStlSeg', p.text, p.surface0)
  call s:hi('MyStlDim', p.overlay1, p.surface0)
  call s:hi('MyStlGit', p.mauve, p.surface0)
  call s:hi('MyStlMod', p.peach, p.surface0, 'bold')
  call s:hi('MyStlEnd', p.surface0, p.mantle)
  call s:hi('MyStlRBeg', p.surface0, p.mantle)
  call s:hi('MyStlFill', p.overlay1, p.mantle)
  call s:hi('MyStlNC', p.overlay0, p.mantle)
  call s:hi('MyStlErr', p.red, p.surface0, 'bold')
  call s:hi('MyStlWarn', p.yellow, p.surface0, 'bold')
  call s:hi('MyStlInfo', p.sky, p.surface0)
  call s:hi('MyStlHint', p.teal, p.surface0)
  for [l:k, l:c] in items({'N': p.blue, 'I': p.green, 'V': p.mauve, 'R': p.red, 'C': p.peach, 'T': p.teal})
    call s:hi('MyStlL' . l:k, l:c, p.mantle)        " tapa izquierda
    call s:hi('MyStlM' . l:k, p.base, l:c, 'bold')  " bloque con el nombre del modo
    call s:hi('MyStlC' . l:k, l:c, p.surface0)      " tapa derecha sobre el segmento
    call s:hi('MyStlRC' . l:k, l:c, p.surface0)     " tapa izquierda del bloque de posición
    call s:hi('MyStlRE' . l:k, l:c, p.mantle)       " tapa final
  endfor
  call s:hi('MyTab', p.overlay1, p.mantle)
  call s:hi('MyTabSel', p.text, p.surface0, 'bold')
  call s:hi('MyTabMod', p.peach, p.mantle)
  call s:hi('MyTabModSel', p.peach, p.surface0, 'bold')
  call s:hi('MyTabAccent', p.blue, p.surface0)
  call s:hi('TabLineFill', p.overlay0, p.mantle)
  call s:hi('TabLine', p.overlay1, p.mantle)
  call s:hi('TabLineSel', p.text, p.surface0, 'bold')
  " Fondo transparente (opcional)
  if get(g:, 'my_transparent', 0)
    for l:g in ['Normal', 'NormalNC', 'SignColumn', 'LineNr', 'CursorLineNr', 'FoldColumn', 'EndOfBuffer']
      execute 'highlight' l:g 'guibg=NONE ctermbg=NONE'
    endfor
  endif
endfunction

" ── Statusline ───────────────────────────────────────────────────────────────
let s:modes = {
  \ 'n': ['NORMAL', 'N'], 'i': ['INSERT', 'I'], 'v': ['VISUAL', 'V'], 'V': ['V-LINE', 'V'],
  \ "\<C-v>": ['V-BLOCK', 'V'], 's': ['SELECT', 'V'], 'S': ['S-LINE', 'V'],
  \ 'R': ['REPLACE', 'R'], 'c': ['COMMAND', 'C'], 't': ['TERMINAL', 'T'], '!': ['SHELL', 'T'],
  \ }

function! s:esc(str) abort
  return substitute(a:str, '%', '%%', 'g')
endfunction

function! s:filename(buf) abort
  let l:bt = getbufvar(a:buf, '&buftype')
  let l:name = bufname(a:buf)
  if l:bt ==# 'terminal' | return 'terminal' | endif
  if l:bt ==# 'quickfix' | return 'quickfix' | endif
  if l:bt ==# 'help' | return fnamemodify(l:name, ':t') | endif
  if empty(l:name) | return '[Sin nombre]' | endif
  let l:p = fnamemodify(l:name, ':~:.')
  return strdisplaywidth(l:p) > 42 ? pathshorten(l:p) : l:p
endfunction

function! s:diagnostics() abort
  if !exists('*LspServerReady') | return '' | endif
  try
    if !LspServerReady() | return '' | endif
    let l:c = lsp#lsp#ErrorCount()
  catch
    return ''
  endtry
  let l:out = ''
  for [l:key, l:grp, l:ico] in [['Error', 'MyStlErr', 'err'], ['Warn', 'MyStlWarn', 'warn'], ['Info', 'MyStlInfo', 'info'], ['Hint', 'MyStlHint', 'hint']]
    if get(l:c, l:key, 0) > 0
      let l:out .= '%#' . l:grp . '#' . my#ui#icon(l:ico) . ' ' . l:c[l:key] . ' '
    endif
  endfor
  return l:out
endfunction

function! my#ui#statusline() abort
  let l:win = g:statusline_winid
  let l:buf = winbufnr(l:win)
  let l:name = s:esc(s:filename(l:buf))
  let l:mod = getbufvar(l:buf, '&modified') ? ' ●' : ''
  let l:ro = (getbufvar(l:buf, '&readonly') || !getbufvar(l:buf, '&modifiable')) && getbufvar(l:buf, '&buftype') ==# '' ? ' ' . my#ui#icon('lock') : ''

  if l:win != win_getid()                       " ventana inactiva: discreta
    return '%#MyStlNC#  ' . l:name . l:mod . l:ro
  endif

  let [l:mname, l:k] = get(s:modes, mode()[0], [toupper(mode()), 'N'])
  let l:wide = winwidth(l:win) >= 90
  let l:s = '%#MyStlL' . l:k . '#' . my#ui#icon('capl')
  let l:s .= '%#MyStlM' . l:k . '# ' . l:mname . ' '
  let l:s .= '%#MyStlC' . l:k . '#' . my#ui#icon('capr')

  " Rama git (si fugitive está cargado)
  let l:branch = exists('*FugitiveHead') ? FugitiveHead() : ''
  if !empty(l:branch)
    let l:s .= '%#MyStlGit# ' . my#ui#icon('branch') . ' ' . s:esc(l:branch) . ' '
  endif
  let l:s .= '%#MyStlSeg# ' . l:name
  let l:s .= '%#MyStlMod#' . l:mod . '%#MyStlDim#' . l:ro . ' '
  let l:s .= '%#MyStlEnd#' . my#ui#icon('capr')

  let l:s .= '%#MyStlFill#%='

  " Lado derecho: diagnósticos · tipo de archivo · posición
  let l:diag = s:diagnostics()
  let l:ft = getbufvar(l:buf, '&filetype')
  let l:r = ''
  if !empty(l:diag) || (l:wide && !empty(l:ft))
    let l:r .= '%#MyStlRBeg#' . my#ui#icon('capl') . '%#MyStlSeg# ' . l:diag
    if l:wide && !empty(l:ft)
      let l:ico = my#ui#icon(l:ft)
      let l:venv = getbufvar(l:buf, 'my_venv', '')
      let l:r .= '%#MyStlDim#' . (empty(l:ico) ? '' : l:ico . ' ') . l:ft . (empty(l:venv) ? '' : ' (' . l:venv . ')') . ' '
    endif
    let l:r .= '%#MyStlRC' . l:k . '#' . my#ui#icon('capl')
  else
    let l:r .= '%#MyStlRE' . l:k . '#' . my#ui#icon('capl')
  endif
  let l:r .= '%#MyStlM' . l:k . '# %3l:%-2c  %P '
  let l:r .= '%#MyStlRE' . l:k . '#' . my#ui#icon('capr')
  return l:s . l:r
endfunction

" ── Bufferline (la tabline muestra los buffers abiertos) ─────────────────────
function! s:listed() abort
  return filter(range(1, bufnr('$')), {_, b -> buflisted(b) && getbufvar(b, '&buftype') ==# ''})
endfunction

function! my#ui#tabline() abort
  let l:bufs = s:listed()
  let l:cur = bufnr('%')
  let l:tails = map(copy(l:bufs), 'fnamemodify(bufname(v:val), ":t")')
  let l:items = []
  for l:i in range(len(l:bufs))
    let l:b = l:bufs[l:i]
    let l:label = empty(l:tails[l:i]) ? '[Sin nombre]' : l:tails[l:i]
    if count(l:tails, l:tails[l:i]) > 1                       " mismo nombre → añade carpeta
      let l:label = fnamemodify(bufname(l:b), ':h:t') . '/' . l:label
    endif
    let l:ico = my#ui#icon(getbufvar(l:b, '&filetype'))
    let l:text = ' ' . (empty(l:ico) ? '' : l:ico . ' ') . l:label . ' '
    call add(l:items, {'nr': l:b, 'text': l:text, 'sel': l:b == l:cur, 'mod': getbufvar(l:b, '&modified')})
  endfor

  " Si no caben todos, recorta por la izquierda manteniendo visible el actual
  let l:first = 0
  let l:budget = &columns - 4
  while l:first < len(l:items) - 1 && s:total(l:items[l:first :]) > l:budget && l:items[l:first].nr != l:cur
    let l:first += 1
  endwhile

  let l:s = l:first > 0 ? '%#MyTab# … ' : ''
  for l:it in l:items[l:first :]
    let l:hl = l:it.sel ? 'MyTabSel' : 'MyTab'
    let l:s .= '%#' . (l:it.sel ? 'MyTabAccent' : 'MyTab') . '#' . (l:it.sel ? '▎' : ' ')
    let l:s .= '%#' . l:hl . '#' . s:esc(l:it.text[1:])
    let l:s .= l:it.mod ? '%#' . (l:it.sel ? 'MyTabModSel' : 'MyTabMod') . '#● ' : ' '
  endfor
  return l:s . '%#TabLineFill#'
endfunction

function! s:total(items) abort
  let l:n = 0
  for l:it in a:items | let l:n += strdisplaywidth(l:it.text) + 3 | endfor
  return l:n
endfunction

" La barra de buffers solo aparece cuando hay más de uno
function! my#ui#tabline_visibility() abort
  let &showtabline = len(s:listed()) > 1 ? 2 : 0
endfunction

" ── Pequeños helpers de UI ───────────────────────────────────────────────────
function! my#ui#foldtext() abort
  let l:line = substitute(getline(v:foldstart), '^\s*', '', '')
  return repeat(' ', indent(v:foldstart)) . '▸ ' . l:line . '  ⋯ ' . (v:foldend - v:foldstart + 1) . ' líneas '
endfunction

" Guías de indentación nativas: una barra fina cada 'shiftwidth' columnas
function! my#ui#indent_guides() abort
  if &buftype !=# '' | return | endif
  let l:sw = &shiftwidth > 0 ? &shiftwidth : &tabstop
  " (con `let &` los espacios van tal cual; el `\ ` solo existe en `:set`)
  let &l:listchars = 'tab:» ,trail:·,nbsp:␣,extends:›,precedes:‹,leadmultispace:│' . repeat(' ', l:sw - 1)
endfunction

function! my#ui#toggle_numbers() abort
  setlocal relativenumber!
  echo &relativenumber ? 'Números relativos' : 'Números absolutos'
endfunction

function! my#ui#bdelete() abort
  let l:cur = bufnr('%')
  if &modified
    echohl WarningMsg | echo 'Hay cambios sin guardar (guarda con <Space>s o fuerza con :bd!)' | echohl None
    return
  endif
  if len(s:listed()) <= 1
    enew
  elseif bufnr('#') > 0 && buflisted(bufnr('#')) && bufnr('#') != l:cur
    buffer #
  else
    bnext
  endif
  silent! execute 'bdelete' l:cur
endfunction

function! my#ui#bonly() abort
  let l:cur = bufnr('%')
  for l:b in s:listed()
    if l:b != l:cur && !getbufvar(l:b, '&modified')
      silent! execute 'bdelete' l:b
    endif
  endfor
endfunction
