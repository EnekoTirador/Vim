" ── plugins/lsp.vim ── autocompletado, diagnósticos, ir a definición... ───────
" yegappan/lsp: cliente LSP escrito en Vim9script puro (sin Node ni Python).
" Los servidores NO se configuran aquí: salen del registro g:my_langs
" (config/languages.vim), y solo se arrancan los que estén instalados.
Plug 'yegappan/lsp'

function! s:servers() abort
  let l:list = []
  for [l:ft, l:lang] in items(g:my_langs)
    for l:group in get(l:lang, 'lsp', [])
      for l:s in l:group
        if executable(l:s.cmd[0])                  " primer instalado de cada grupo
          call add(l:list, extend({'name': l:s.name, 'filetype': [l:ft],
                \ 'path': l:s.cmd[0], 'args': l:s.cmd[1 :]}, get(l:s, 'extra', {})))
          break
        endif
      endfor
    endfor
  endfor
  return l:list
endfunction

function! s:setup() abort
  call LspOptionsSet({
        \ 'autoComplete': v:true,
        \ 'completionMatcher': 'icase',
        \ 'useBufferCompletion': v:true,
        \ 'snippetSupport': v:false,
        \ 'ignoreMissingServer': v:true,
        \ 'autoHighlightDiags': v:true,
        \ 'highlightDiagInline': v:true,
        \ 'showDiagWithSign': v:true,
        \ 'showDiagWithVirtualText': v:true,
        \ 'diagVirtualTextAlign': 'after',
        \ 'diagSignErrorText': my#ui#icon('err') . ' ',
        \ 'diagSignWarningText': my#ui#icon('warn') . ' ',
        \ 'diagSignInfoText': my#ui#icon('info') . ' ',
        \ 'diagSignHintText': my#ui#icon('hint') . ' ',
        \ 'popupBorder': v:true,
        \ 'usePopupInCodeAction': v:true,
        \ 'outlineOnRight': v:true,
        \ 'outlineWinSize': 34,
        \ })
  call LspAddServer(s:servers())
endfunction
autocmd User LspSetup call s:setup()

" Atajos que solo existen en buffers con un servidor activo
function! s:on_attach() abort
  let l:b = {'buffer': 1}
  call my#keys#map('n', 'gd', '<Cmd>LspGotoDefinition<CR>', 'Ir a la definición', l:b)
  call my#keys#map('n', 'gD', '<Cmd>LspGotoDeclaration<CR>', 'Ir a la declaración', l:b)
  call my#keys#map('n', 'gi', '<Cmd>LspGotoImpl<CR>', 'Ir a la implementación', l:b)
  call my#keys#map('n', 'gy', '<Cmd>LspGotoTypeDef<CR>', 'Ir a la definición del tipo', l:b)
  call my#keys#map('n', 'gr', '<Cmd>LspShowReferences<CR>', 'Ver referencias', l:b)
  call my#keys#map('n', 'K', '<Cmd>LspHover<CR>', 'Documentación bajo el cursor', l:b)
  call my#keys#map('n', '<leader>la', '<Cmd>LspCodeAction<CR>', 'Acciones de código (arreglos)', l:b)
  call my#keys#map('n', '<leader>lr', '<Cmd>LspRename<CR>', 'Renombrar símbolo', l:b)
  call my#keys#map('n', '<leader>ls', '<Cmd>LspDocumentSymbol<CR>', 'Símbolos de este archivo', l:b)
  call my#keys#map('n', '<leader>lS', '<Cmd>LspSymbolSearch<CR>', 'Buscar símbolo en el proyecto', l:b)
  call my#keys#map('n', '<leader>lo', '<Cmd>LspOutline<CR>', 'Panel de esquema', l:b)
  call my#keys#map('n', '<leader>ld', '<Cmd>LspDiag show<CR>', 'Lista de diagnósticos', l:b)
  call my#keys#map('n', '<leader>lx', '<Cmd>LspServer restart<CR>', 'Reiniciar servidor', l:b)
  setlocal formatexpr=lsp#lsp#FormatExpr()
endfunction
autocmd User LspAttached call s:on_attach()

function! s:toggle_vtext() abort
  let g:my_lsp_vtext = !get(g:, 'my_lsp_vtext', 1)
  call LspOptionsSet({'showDiagWithVirtualText': g:my_lsp_vtext ? v:true : v:false})
  echo 'Diagnósticos en línea: ' . (g:my_lsp_vtext ? 'sí' : 'no')
endfunction

call my#keys#map('n', ']d', '<Cmd>LspDiagNextWrap<CR>', 'Siguiente diagnóstico')
call my#keys#map('n', '[d', '<Cmd>LspDiagPrevWrap<CR>', 'Diagnóstico anterior')
call my#keys#map('n', '<leader>li', '<Cmd>LspShowAllServers<CR>', 'Servidores LSP activos')
call my#keys#map('n', '<leader>ud', '<Cmd>call <SID>toggle_vtext()<CR>', 'Diagnósticos en línea')
