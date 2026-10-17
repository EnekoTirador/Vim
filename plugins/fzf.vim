" ── plugins/fzf.vim ── búsqueda difusa de todo ─────────────────────────────────
" Requiere el binario `fzf` en el PATH (con bin/vimx en NixOS ya lo tienes).
" Si no está, el hook de abajo lo descarga dentro de ./plugged.
Plug 'junegunn/fzf', { 'do': { -> executable('fzf') ? 0 : fzf#install() } }
Plug 'junegunn/fzf.vim'

" ── Aspecto: popup flotante, colores heredados del tema activo ───────────────
let g:fzf_layout = {'window': {'width': 0.9, 'height': 0.82, 'border': 'rounded', 'highlight': 'MyFloatBorder'}}
let g:fzf_vim = {'preview_window': ['right,56%', 'ctrl-/']}
let g:fzf_action = {'ctrl-t': 'tab split', 'ctrl-s': 'split', 'ctrl-v': 'vsplit'}
let g:fzf_colors = {
  \ 'fg':      ['fg', 'Normal'],      'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Statement'],   'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],   'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],      'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],   'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],       'header':  ['fg', 'Comment'] }
if empty($FZF_DEFAULT_OPTS)
  let $FZF_DEFAULT_OPTS = "--layout=reverse --info=inline --prompt='❯ ' --pointer='▌' --marker='✚' --bind=ctrl-d:half-page-down,ctrl-u:half-page-up"
endif

" ── Comandos propios ─────────────────────────────────────────────────────────
" Archivos desde la RAÍZ del proyecto (no desde donde abriste Vim)
command! -bang ProjectFiles call fzf#vim#files(my#lang#root(), fzf#vim#with_preview(), <bang>0)
" Búsqueda de texto en vivo (ripgrep se relanza en cada tecla), también desde la raíz
command! -bang -nargs=* ProjectGrep call fzf#vim#grep2(
  \ 'rg --column --line-number --no-heading --color=always --smart-case -- ', <q-args>,
  \ fzf#vim#with_preview({'dir': my#lang#root()}), <bang>0)
" Archivos de ESTA configuración de Vim
command! ConfigFiles call fzf#vim#files(g:my_root, fzf#vim#with_preview({'options': ['--prompt', 'Config> ']}), 0)
" Elegir sabor del tema
command! Theme call fzf#run(fzf#wrap({
  \ 'source': g:my_flavors, 'sink': {f -> my#ui#colorscheme(f)},
  \ 'options': ['--prompt', 'Tema> ', '--no-preview'], 'window': {'width': 0.3, 'height': 0.3, 'border': 'rounded'}}))

" ── Atajos ───────────────────────────────────────────────────────────────────
call my#keys#map('n', '<leader><leader>', '<Cmd>ProjectFiles<CR>', 'Archivos del proyecto')
call my#keys#map('n', '<leader>/', '<Cmd>ProjectGrep<CR>', 'Buscar texto en el proyecto (en vivo)')
call my#keys#map('n', '<leader>,', '<Cmd>Buffers<CR>', 'Buffers abiertos')
call my#keys#map('n', '<leader>ff', '<Cmd>ProjectFiles<CR>', 'Archivos del proyecto')
call my#keys#map('n', '<leader>fg', '<Cmd>ProjectGrep<CR>', 'Buscar texto (en vivo)')
call my#keys#map('n', '<leader>fw', '<Cmd>execute "Rg" expand("<cword>")<CR>', 'Buscar la palabra bajo el cursor')
call my#keys#map('n', '<leader>fr', '<Cmd>History<CR>', 'Archivos recientes')
call my#keys#map('n', '<leader>fb', '<Cmd>Buffers<CR>', 'Buffers abiertos')
call my#keys#map('n', '<leader>fl', '<Cmd>BLines<CR>', 'Líneas de este archivo')
call my#keys#map('n', '<leader>fh', '<Cmd>Helptags<CR>', 'Ayuda de Vim')
call my#keys#map('n', '<leader>fc', '<Cmd>Commands<CR>', 'Comandos')
call my#keys#map('n', '<leader>fm', '<Cmd>Marks<CR>', 'Marcas')
call my#keys#map('n', '<leader>ft', '<Cmd>Theme<CR>', 'Elegir tema')
call my#keys#map('n', '<leader>cf', '<Cmd>ConfigFiles<CR>', 'Abrir un archivo de la config')
