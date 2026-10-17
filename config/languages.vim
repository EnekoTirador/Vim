" ── config/languages.vim ── REGISTRO DE LENGUAJES ──────────────────────────────
"
" Aquí vive TODO lo específico de cada lenguaje. Para añadir uno nuevo (Rust,
" Go, Lua...) basta una entrada en g:my_langs: el ejecutor (<Space>rr), el
" formateador (<Space>lf), el REPL, los servidores LSP y el :Doctor la leen solos.
" (El indentado y opciones del buffer van en after/ftplugin/<lenguaje>.vim)
"
"   run      Cómo ejecutar el archivo. String, o lista de [regex_del_archivo, comando]
"            (gana la primera regla que encaje; regex vacía = por defecto).
"   shebang  1 → si el archivo es ejecutable y empieza por #!, se ejecuta tal cual.
"   fmt      Formateadores como filtro stdin→stdout. Gana el primero que esté instalado.
"   lsp      Lista de GRUPOS de servidores. En cada grupo gana el primero instalado,
"            y los grupos se suman (p. ej. pyright para tipos + ruff para lint).
"   repl     REPLs alternativos, gana el primero instalado. paste=1 → pegado seguro
"            (bracketed paste) para bloques multilínea.
"
"   Marcadores que puedes usar en los comandos:
"     {file} {dir} {name} {root}   archivo, carpeta, nombre sin extensión, raíz del proyecto
"     {python}                     .venv/bin/python del proyecto, o python3
"     {sw}                         valor actual de 'shiftwidth'

let g:my_langs = {}

" Marcadores que delatan la raíz de un proyecto (gana el más cercano al archivo)
let g:my_root_markers = ['.git', 'flake.nix', 'pyproject.toml', 'setup.py', 'setup.cfg',
  \ 'requirements.txt', 'shell.nix', 'default.nix', 'Makefile', '.root']

" ── Python ───────────────────────────────────────────────────────────────────
let g:my_langs.python = {
  \ 'run': '{python} {file}',
  \ 'fmt': ['ruff format --quiet --stdin-filename {file} -', 'black --quiet -'],
  \ 'lsp': [
  \   [{'name': 'pyright',      'cmd': ['pyright-langserver', '--stdio']},
  \    {'name': 'basedpyright', 'cmd': ['basedpyright-langserver', '--stdio']},
  \    {'name': 'pylsp',        'cmd': ['pylsp']}],
  \   [{'name': 'ruff',         'cmd': ['ruff', 'server']}],
  \ ],
  \ 'repl': [
  \   {'cmd': 'ipython --no-banner', 'paste': 1},
  \   {'cmd': 'env PYTHON_BASIC_REPL=1 {python} -q', 'paste': 0},
  \ ],
  \ }

" ── Bash / sh ────────────────────────────────────────────────────────────────
let g:my_langs.sh = {
  \ 'run': 'bash {file}',
  \ 'shebang': 1,
  \ 'fmt': ['shfmt -i {sw} -ci -'],
  \ 'lsp': [[{'name': 'bashls', 'cmd': ['bash-language-server', 'start']}]],
  \ 'repl': [{'cmd': 'bash', 'paste': 1}],
  \ }

" ── Nix ──────────────────────────────────────────────────────────────────────
let g:my_langs.nix = {
  \ 'run': [
  \   ['flake\.nix$', 'nix flake check'],
  \   ['shell\.nix$', 'nix-shell {file}'],
  \   ['default\.nix$', 'nix-build {file}'],
  \   ['',            'nix-instantiate --eval --strict {file}'],
  \ ],
  \ 'fmt': ['nixfmt', 'alejandra --quiet -', 'nixpkgs-fmt'],
  \ 'lsp': [[{'name': 'nil',  'cmd': ['nil']},
  \          {'name': 'nixd', 'cmd': ['nixd']}]],
  \ 'repl': [{'cmd': 'nix repl', 'paste': 0}],
  \ }

" ── Herramientas generales (solo informativas: las enseña :Doctor) ───────────
let g:my_tools = {
  \ 'fzf':     'buscador difuso (todo <Space>f...)',
  \ 'rg':      'ripgrep: buscar texto y listar archivos rápido',
  \ 'git':     'plugins, ramas, hunks',
  \ 'bat':     'vista previa con colores en fzf',
  \ 'lazygit': 'cliente git a pantalla completa (<Space>gg)',
  \ }

" Sintaxis más rica con lo que ya trae Vim
let g:python_highlight_all = 1
let g:sh_fold_enabled = 0

" Si hay rg, fzf lo usa para listar archivos (respeta .gitignore, muy rápido)
if executable('rg') && empty($FZF_DEFAULT_COMMAND)
  let $FZF_DEFAULT_COMMAND = "rg --files --hidden --glob '!.git' --glob '!plugged' --glob '!node_modules' --glob '!__pycache__'"
endif

" Formateo: al guardar (alternable con <Space>uf) y limpiar espacios sobrantes
let g:my_format_on_save = get(g:, 'my_format_on_save', 0)
let g:my_trim_on_save = get(g:, 'my_trim_on_save', 1)

call my#keys#map('n', '<leader>lf', '<Cmd>call my#fmt#buffer()<CR>', 'Formatear archivo')
