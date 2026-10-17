" ── config/keys.vim ── atajos generales (los de cada plugin viven en su archivo)
"
" Convención: TODOS los atajos nuevos se definen con my#keys#map(), no con
" nnoremap a pelo. Así quedan registrados con su descripción y aparecen
" automáticamente en:
"     · el mini which-key (pulsa <Space> y espera)
"     · el buscador de atajos <Space>?  (:Keys)
"
"   call my#keys#map({modos}, {lhs}, {rhs}, {descripción} [, {opciones}])
"   opciones: {'buffer': 1, 'expr': 1, 'hide': 1}

let g:mapleader = "\<Space>"
let g:maplocalleader = ','

" Nombre de cada grupo <leader>X (para which-key y :Keys). Añade el tuyo aquí.
let g:my_key_groups = {
  \ 'f': 'Buscar (fzf)',
  \ 'g': 'Git',
  \ 'l': 'Código / LSP',
  \ 'r': 'Ejecutar / REPL',
  \ 't': 'Terminal',
  \ 'b': 'Buffers',
  \ 'w': 'Ventanas',
  \ 'u': 'Interfaz',
  \ 'c': 'Config de Vim',
  \ }

" <Space> a secas abre el which-key (solo salta si dejas de teclear: timeoutlen)
nnoremap <silent> <leader> <Cmd>call my#keys#hint()<CR>

" ── Básicos ──────────────────────────────────────────────────────────────────
call my#keys#map('n', '<Esc>', '<Cmd>nohlsearch<CR>', 'Quitar resaltado de búsqueda')
call my#keys#map('n', 'Y', 'y$', 'Copiar hasta el final de la línea')
call my#keys#map('n', 'j', "v:count ? 'j' : 'gj'", 'Bajar por línea visual', {'expr': 1, 'hide': 1})
call my#keys#map('n', 'k', "v:count ? 'k' : 'gk'", 'Subir por línea visual', {'expr': 1, 'hide': 1})
call my#keys#map('x', '<', '<gv', 'Desindentar y mantener selección')
call my#keys#map('x', '>', '>gv', 'Indentar y mantener selección')
call my#keys#map('x', 'p', 'P', 'Pegar sin pisar el registro')
call my#keys#map('x', 'J', ":m '>+1<CR>gv=gv", 'Mover selección abajo')
call my#keys#map('x', 'K', ":m '<-2<CR>gv=gv", 'Mover selección arriba')
call my#keys#map('n', '<leader>s', '<Cmd>update<CR>', 'Guardar')
call my#keys#map('n', '<leader>q', '<Cmd>close<CR>', 'Cerrar ventana')
call my#keys#map('n', '<leader>Q', '<Cmd>confirm qall<CR>', 'Salir de Vim')

" ── Moverse entre ventanas y buffers ─────────────────────────────────────────
call my#keys#map('n', '<C-h>', '<C-w>h', 'Ventana izquierda')
call my#keys#map('n', '<C-j>', '<C-w>j', 'Ventana inferior')
call my#keys#map('n', '<C-k>', '<C-w>k', 'Ventana superior')
call my#keys#map('n', '<C-l>', '<C-w>l', 'Ventana derecha')
call my#keys#map('n', 'L', '<Cmd>bnext<CR>', 'Buffer siguiente')
call my#keys#map('n', 'H', '<Cmd>bprevious<CR>', 'Buffer anterior')

" ── <leader>b  Buffers ───────────────────────────────────────────────────────
call my#keys#map('n', '<leader>bd', '<Cmd>call my#ui#bdelete()<CR>', 'Cerrar buffer (sin cerrar la ventana)')
call my#keys#map('n', '<leader>bo', '<Cmd>call my#ui#bonly()<CR>', 'Cerrar todos los demás')
call my#keys#map('n', '<leader>bn', '<Cmd>bnext<CR>', 'Siguiente')
call my#keys#map('n', '<leader>bp', '<Cmd>bprevious<CR>', 'Anterior')

" ── <leader>w  Ventanas ──────────────────────────────────────────────────────
call my#keys#map('n', '<leader>wv', '<Cmd>vsplit<CR>', 'Dividir en vertical')
call my#keys#map('n', '<leader>ws', '<Cmd>split<CR>', 'Dividir en horizontal')
call my#keys#map('n', '<leader>wc', '<Cmd>close<CR>', 'Cerrar')
call my#keys#map('n', '<leader>wo', '<Cmd>only<CR>', 'Dejar solo esta')
call my#keys#map('n', '<leader>w=', '<C-w>=', 'Igualar tamaños')

" ── <leader>u  Interruptores de interfaz ─────────────────────────────────────
call my#keys#map('n', '<leader>un', '<Cmd>call my#ui#toggle_numbers()<CR>', 'Números relativos / absolutos')
call my#keys#map('n', '<leader>uw', '<Cmd>setlocal wrap!<CR>', 'Ajuste de línea')
call my#keys#map('n', '<leader>us', '<Cmd>setlocal spell!<CR>', 'Corrector ortográfico')
call my#keys#map('n', '<leader>ul', '<Cmd>setlocal list!<CR>', 'Caracteres invisibles / guías de indentación')
call my#keys#map('n', '<leader>ut', '<Cmd>call my#ui#cycle_flavor()<CR>', 'Cambiar sabor del tema')
call my#keys#map('n', '<leader>ub', '<Cmd>call my#ui#toggle_transparent()<CR>', 'Fondo transparente')
call my#keys#map('n', '<leader>uf', '<Cmd>call my#fmt#toggle_on_save()<CR>', 'Formatear al guardar')

" ── <leader>c  La propia config ──────────────────────────────────────────────
call my#keys#map('n', '<leader>cr', '<Cmd>call my#ui#reload()<CR>', 'Recargar config')
call my#keys#map('n', '<leader>cd', '<Cmd>Doctor<CR>', 'Doctor: ¿qué herramientas me faltan?')
call my#keys#map('n', '<leader>cp', '<Cmd>PlugStatus<CR>', 'Estado de los plugins')
call my#keys#map('n', '<leader>cu', '<Cmd>PlugUpdate<CR>', 'Actualizar plugins')

" ── Buscador de atajos ───────────────────────────────────────────────────────
call my#keys#map('n', '<leader>?', '<Cmd>Keys<CR>', 'Buscar atajos y comandos')
command! Keys call my#keys#search()
