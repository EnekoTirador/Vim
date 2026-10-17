" ── config/options.vim ── opciones del editor (sin plugins) ───────────────────

filetype plugin indent on
syntax enable

" ── Color real y cursor ──────────────────────────────────────────────────────
if has('termguicolors')
  " Necesario dentro de tmux/screen, donde Vim no siempre lo autodetecta
  if empty(&t_8f) | let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum" | endif
  if empty(&t_8b) | let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum" | endif
  set termguicolors
  let &t_ut = ''                 " pinta el fondo explícitamente (kitty/tmux borraban con otro color)
endif
if !has('gui_running') && &term !~# 'linux'
  let &t_SI = "\<Esc>[6 q"    " insertar  → barra
  let &t_SR = "\<Esc>[4 q"    " reemplazar → subrayado
  let &t_EI = "\<Esc>[2 q"    " normal    → bloque
endif

" ── Interfaz ─────────────────────────────────────────────────────────────────
set number relativenumber cursorline signcolumn=yes
set scrolloff=8 sidescrolloff=8
set laststatus=2 noshowmode noruler showcmd cmdheight=1
set mouse=a
set belloff=all
set shortmess+=cI shortmess-=S         " sin intro; muestra [3/10] al buscar
set splitbelow splitright
set linebreak breakindent
let &showbreak = '↪ '                   " ajuste de línea elegante
silent! set smoothscroll
let &fillchars = 'vert:│,fold:─,foldopen:▾,foldclose:▸,foldsep:│,diff:╱,eob: ,lastline:…,stl: ,stlnc: '
set list listchars=tab:»\ ,trail:·,nbsp:␣,extends:›,precedes:‹
set foldmethod=indent foldlevelstart=99 foldtext=my#ui#foldtext()

" ── Menú de completado y línea de comandos ───────────────────────────────────
set wildmenu wildmode=longest:full,full
silent! set wildoptions=pum            " menú emergente al completar con <Tab>
silent! set wildoptions+=fuzzy         " ... y con coincidencia difusa (Vim reciente)
set completeopt=menuone,noselect,popup pumheight=12

" ── Edición ──────────────────────────────────────────────────────────────────
set expandtab shiftwidth=4 softtabstop=4 tabstop=4
set autoindent smartindent
set backspace=indent,eol,start
set hidden nrformats-=octal virtualedit=block
set matchpairs+=<:>
set formatoptions=jcrql
set spelllang=es,en nospell

" ── Búsqueda ─────────────────────────────────────────────────────────────────
set ignorecase smartcase incsearch hlsearch
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case
  set grepformat=%f:%l:%c:%m
endif

" ── Archivos, undo persistente y rapidez ─────────────────────────────────────
set undofile
let &undodir = g:my_state . '/undo//'
let &directory = g:my_state . '/swap//'
set nobackup nowritebackup             " los servidores LSP odian los .bak
let &viminfo = "'200,<500,s100,h,n" . g:my_state . '/viminfo'
set history=2000 autoread
set updatetime=250 timeoutlen=350 ttimeoutlen=10
set termwinscroll=20000

if has('clipboard') | set clipboard=unnamed,unnamedplus | endif

" ── Diff moderno ─────────────────────────────────────────────────────────────
set diffopt+=vertical,algorithm:patience,indent-heuristic
silent! set diffopt+=inline:char

" ── Paquetes que vienen con Vim (no son plugins nuestros) ────────────────────
packadd! matchit                       " % salta if/fi, do/done, ...
runtime! ftplugin/man.vim              " :Man (la K de shell lo usa)
