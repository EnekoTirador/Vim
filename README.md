# Vim modular · Python · Bash · Nix

Toda la configuración vive en **una sola carpeta** (`~/.config/vim`). Tu `~/.vimrc`
solo tiene una línea:

```vim
source ~/.config/vim/vimrc
```

No toca tu configuración de NixOS, no instala nada en el sistema y se copia tal cual
a otro PC (los plugins se descargan solos la primera vez).

---

## Instalación (3 pasos)

```bash
# 1. Copia la carpeta
mkdir -p ~/.config && cp -r vim ~/.config/vim        # o: git clone <tu repo> ~/.config/vim

# 2. Conecta ~/.vimrc y descarga los plugins
~/.config/vim/install.sh                             # (--append si quieres conservar tu ~/.vimrc)

# 3. Abre Vim con todas las herramientas (en NixOS, sin tocar el sistema)
~/.config/vim/bin/vimx archivo.py
```

Si prefieres no usar el script: `echo 'source ~/.config/vim/vimrc' > ~/.vimrc` y abre Vim;
los plugins se instalan solos en el primer arranque (necesita `git` y red).

**Fuente:** usa una [Nerd Font](https://www.nerdfonts.com/) en tu terminal para ver los iconos.
Si no puedes, pon `let g:my_nerdfont = 0` en `local.vim` (ver más abajo).

### En NixOS: `vimx`

`bin/vimx` abre Vim dentro de un `nix-shell` efímero (`nix/shell.nix`) que trae fzf,
ripgrep, bat, lazygit, ruff, pyright, bash-language-server, shellcheck, shfmt, nil y un
formateador de Nix. Al cerrar Vim todo desaparece: **tu configuración de NixOS no se modifica**.

- Si ya tienes las herramientas en el PATH, `vimx` abre Vim directamente.
- `VIMX_FORCE=1 vimx` fuerza el shell de nix · `VIMX_NO_NIX=1 vimx` lo evita.
- Cómodo: `alias vim=~/.config/vim/bin/vimx` en tu shell.
- Para añadir una herramienta, edita `nix/shell.nix`.

---

## Estructura

```
~/.config/vim
├── vimrc                  punto de entrada: define rutas y carga los módulos EN ORDEN
├── config/                el "núcleo", un tema por archivo
│   ├── options.vim          opciones de Vim
│   ├── keys.vim             atajos generales + registro de atajos
│   ├── languages.vim        ★ registro de lenguajes (cómo ejecutar, formatear, LSP, REPL)
│   ├── plugins.vim          carga vim-plug y todos los plugins/*.vim
│   ├── ui.vim               tema, statusline, tabline, guías de indentación
│   ├── terminal.vim         atajos del terminal flotante
│   └── autocmds.vim         autocomandos
├── plugins/               ★ un archivo por grupo de plugins (suelta uno nuevo y se carga solo)
│   ├── theme · editing · lang · git · fzf · lsp .vim
├── after/ftplugin/        ajustes por tipo de archivo (python, sh, nix)
├── autoload/my/           la lógica (funciones): keys, palette, ui, lang, fmt, float, run, doctor
├── autoload/plug.vim      vim-plug incluido (no hace falta descargarlo)
├── bin/vimx               lanzador para NixOS
├── nix/shell.nix          herramientas para vimx
├── install.sh             instalador
├── local.vim.example      plantilla de ajustes propios de cada PC
└── plugged/               plugins descargados (no se versiona)
```

Regla de oro: **configuración = datos en registros; lógica = autoload.**
Para cambiar algo casi nunca hay que tocar la lógica.

---

## Atajos

`<leader>` = **Espacio**. Pulsa Espacio y espera un instante: aparece un menú (estilo
which-key) con todo lo que puedes pulsar a continuación. `Espacio ?` abre un fzf con
**todos** los atajos y su descripción.

### Ejecutar y terminal flotante

| Atajo | Acción |
|---|---|
| `F12` / `Espacio tt` | Mostrar/ocultar el terminal flotante (el shell sigue vivo al ocultarlo) |
| `F5` / `Espacio rr` | Ejecutar el archivo actual en el terminal flotante |
| `Espacio ra` | Ejecutar pidiendo argumentos |
| `Espacio rl` | Repetir la última ejecución |
| `Espacio rp` | REPL del lenguaje (ipython / bash / nix repl) |
| `Espacio rs` | Enviar línea (o selección en visual) al REPL |
| `Esc Esc` (en el terminal) | Pasar a modo Normal del terminal |
| `Espacio tk` | Matar los terminales flotantes |

El comando se decide por lenguaje (`config/languages.vim`): Python usa el `.venv` del
proyecto si existe, Bash respeta el shebang, y en Nix `flake.nix` → `nix flake check`,
`shell.nix` → `nix-shell`, otros → `nix-instantiate --eval`.

### fzf

| Atajo | Acción |
|---|---|
| `Espacio Espacio` / `Espacio ff` | Archivos del proyecto |
| `Espacio /` / `Espacio fg` | Buscar texto en vivo (ripgrep) |
| `Espacio ,` / `Espacio fb` | Buffers |
| `Espacio fw` | Buscar la palabra bajo el cursor |
| `Espacio fr` | Archivos recientes |
| `Espacio fl` | Líneas de este archivo |
| `Espacio fc` / `fh` / `fm` | Comandos / ayuda / marcas |
| `Espacio ft` | Elegir tema |
| `Espacio cf` | Abrir un archivo de esta config |

### Código (LSP) y formato

`gd` definición · `gD` declaración · `gi` implementación · `gy` tipo · `gr` referencias ·
`K` documentación · `]d` / `[d` diagnósticos · `Espacio la` acciones · `Espacio lr` renombrar ·
`Espacio ls` / `lS` símbolos · `Espacio lo` esquema · `Espacio ld` lista de diagnósticos ·
`Espacio lf` formatear · `Espacio uf` formatear al guardar (on/off) ·
`Espacio lx` reiniciar servidor · `Espacio li` servidores activos.

### Git

`Espacio gs` estado · `gb` blame · `gd` diff · `gl` / `gL` historial (fzf) · `gh` ver hunk ·
`gu` deshacer hunk · `gg` lazygit a pantalla completa · `]c` / `[c` entre cambios.

### General

`Espacio s` guardar · `q` cerrar ventana · `Q` salir · `H` / `L` buffer anterior/siguiente ·
`Ctrl-h/j/k/l` moverse entre ventanas · `Espacio bd` cerrar buffer · `Espacio w…` ventanas ·
`J` / `K` en visual mueven la selección · `gcc` comentar · `ysiw)` rodear.

### Interfaz y mantenimiento

`Espacio ut` cambiar sabor del tema · `ub` fondo transparente · `un` números relativos ·
`ul` invisibles · `ud` diagnósticos en línea · `Espacio cd` **:Doctor** (qué te falta en este PC) ·
`cr` recargar config · `cp` / `cu` estado / actualizar plugins.

---

## Cómo ampliar

### Añadir un lenguaje (p. ej. Go)

Un bloque en `config/languages.vim`; el ejecutor, el formateador, el LSP, el REPL y
`:Doctor` lo recogen solos:

```vim
let g:my_langs.go = {
  \ 'run':  'go run {file}',
  \ 'fmt':  ['gofmt'],
  \ 'lsp':  [[{'name': 'gopls', 'cmd': ['gopls']}]],
  \ }
```

Placeholders disponibles: `{file} {dir} {name} {root} {python} {sw}`. En `lsp`, cada grupo es
una lista de alternativas (se usa la primera instalada) y se pueden tener varios grupos a la vez
(como pyright + ruff en Python).

### Añadir un plugin

Crea `plugins/loquesea.vim` con `Plug 'usuario/repo'` y sus ajustes. Se carga solo;
`:PlugInstall` (o reabrir Vim) lo descarga.

### Añadir un atajo

```vim
call my#keys#map('n', '<leader>xx', '<Cmd>MiComando<CR>', 'Descripción que verás en el menú')
```

Aparece automáticamente en el menú de Espacio y en `Espacio ?`.

### Ajustes de cada PC

`cp local.vim.example local.vim` y descomenta lo que quieras. `local.vim` (antes de la
config) y `local.after.vim` (después) están en `.gitignore`, así que no se mezclan entre máquinas.
También se cargan `plugins/local-*.vim`.

```vim
let g:my_flavor = 'macchiato'     " mocha | macchiato | frappe | latte
let g:my_nerdfont = 0             " sin Nerd Font
let g:my_transparent = 1
let g:my_float = {'width': 0.95, 'height': 0.9}
let g:my_format_on_save = 1
let g:my_no_autoinstall = 1
```

---

## Si algo falla

- `:Doctor` (`Espacio cd`) lista qué herramientas faltan y dónde están las que hay.
- Si un módulo falla al cargar, Vim sigue arrancando y muestra el error en el mensaje de inicio.
- Iconos rotos → `let g:my_nerdfont = 0`.
- Los plugins no se descargan → comprueba `git` y red, luego `:PlugInstall`.
- Requiere Vim ≥ 9.0 con `+terminal` y `+popupwin` (el LSP usa Vim9script).
# Vim
