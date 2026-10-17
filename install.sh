#!/usr/bin/env bash
# install.sh — conecta ~/.vimrc con esta carpeta e instala los plugins.
#
# Es seguro ejecutarlo varias veces. Solo toca:
#   · ~/.vimrc            (con copia de seguridad si ya tenías uno)
#   · <esta carpeta>/plugged   (los plugins)
#   · ~/.local/state/vim       (undo, swap, historial)
# No toca tu configuración de NixOS ni instala nada en el sistema.
#
#   ./install.sh           ~/.vimrc = una línea `source ...` (guarda el anterior en .bak)
#   ./install.sh --append  en lugar de reemplazar, añade la línea al final de tu ~/.vimrc
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
VIMRC="$HOME/.vimrc"

say() { printf '\033[1;35m▸\033[0m %s\n' "$*"; }
ok()  { printf '\033[1;32m✔\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*" >&2; }

command -v vim >/dev/null || { warn "No encuentro 'vim' en el PATH."; exit 1; }
command -v git >/dev/null || { warn "Hace falta 'git' para descargar los plugins."; exit 1; }

# Ruta con ~ si la carpeta está en el sitio habitual (queda más legible)
if [[ "$ROOT" == "$HOME/.config/vim" ]]; then TARGET='~/.config/vim/vimrc'; else TARGET="$ROOT/vimrc"; fi
LINE="source $TARGET"

# 1) ~/.vimrc ─────────────────────────────────────────────────────────────────
if [[ -f "$VIMRC" ]] && grep -qxF "$LINE" "$VIMRC"; then
  ok "~/.vimrc ya apunta a $TARGET"
elif [[ -f "$VIMRC" && "${1:-}" == "--append" ]]; then
  printf '\n" Configuración modular de Vim\n%s\n' "$LINE" >> "$VIMRC"
  ok "Añadida la línea a ~/.vimrc"
else
  if [[ -f "$VIMRC" ]]; then
    BAK="$VIMRC.bak.$(date +%Y%m%d-%H%M%S)"
    cp "$VIMRC" "$BAK"
    warn "Tu ~/.vimrc anterior está guardado en $BAK"
  fi
  printf '" Toda la configuración vive en %s\n%s\n' "$ROOT" "$LINE" > "$VIMRC"
  ok "~/.vimrc ahora solo contiene: $LINE"
fi

# 2) Plugins ──────────────────────────────────────────────────────────────────
say "Instalando plugins en $ROOT/plugged ..."
MY_VIM_NO_AUTOINSTALL=1 vim -Nes -u "$VIMRC" -c 'PlugInstall --sync' -c 'qa!' </dev/null >/dev/null 2>&1 || true
n=$(find "$ROOT/plugged" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
if ((n > 0)); then ok "$n plugins instalados"; else warn "No se instaló ningún plugin (¿sin red?). Se reintentará al abrir Vim."; fi

# 3) Qué falta en esta máquina ────────────────────────────────────────────────
say "Estado de las herramientas:"
MY_VIM_NO_AUTOINSTALL=1 vim -Nes -u "$VIMRC" -c 'call my#doctor#print()' -c 'qa!' </dev/null 2>/dev/null || true

if command -v nix-shell >/dev/null 2>&1; then
  echo
  say "Detecto Nix. Para tener fzf, LSPs y formateadores SIN tocar tu NixOS, abre Vim con:"
  echo "      $ROOT/bin/vimx archivo.py"
  echo "   (opcional, en tu shell:  alias vim=$ROOT/bin/vimx)"
fi
echo
ok "Listo. Abre Vim y pulsa <Espacio> para ver el menú de atajos."
