# nix/shell.nix — herramientas que usa esta configuración de Vim.
#
# NO instala nada en tu sistema ni toca tu configuración de NixOS: todo vive
# solo dentro de este shell efímero y desaparece al salir.
#
#   nix-shell ~/.config/vim/nix/shell.nix      # entras en un shell con todo
#   ~/.config/vim/bin/vimx archivo.py          # o directamente Vim con todo (recomendado)
#
# Para añadir una herramienta: ponla en la lista que corresponda abajo.
{ pkgs ? import <nixpkgs> { } }:

let
  # nixpkgs renombra paquetes a menudo (nixfmt-rfc-style → nixfmt, etc.).
  # `pick` coge el PRIMER nombre que exista en tu versión de nixpkgs, y si no hay
  # ninguno lo omite en lugar de romper el shell entero.
  pick = names:
    let
      ok = n: pkgs ? ${n} && (builtins.tryEval pkgs.${n}).success;
      found = builtins.filter ok names;
    in
    if found == [ ] then [ ] else [ pkgs.${builtins.head found} ];

  # Python con ipython para el REPL (<Space>rp). El Python de tu proyecto
  # (.venv) tiene prioridad al ejecutar archivos: ver config/languages.vim.
  python = pkgs.python3.withPackages (ps: [ ps.ipython ]);
in
pkgs.mkShell {
  name = "vim-tools";

  packages =
    # ── Núcleo: búsqueda difusa, ripgrep, vista previa, git ───────────────────
    (with pkgs; [ fzf ripgrep fd bat git lazygit ])

    # ── Python ────────────────────────────────────────────────────────────────
    ++ [ python ]
    ++ pick [ "ruff" ] # formateo + lint (LSP y <Space>lf)
    ++ pick [ "pyright" "basedpyright" ] # tipos y autocompletado

    # ── Bash ──────────────────────────────────────────────────────────────────
    ++ pick [ "bash-language-server" ]
    ++ pick [ "shellcheck" ] # diagnósticos dentro de bash-language-server
    ++ pick [ "shfmt" ]

    # ── Nix ───────────────────────────────────────────────────────────────────
    ++ pick [ "nil" "nixd" ]
    ++ pick [ "nixfmt" "nixfmt-rfc-style" "alejandra" "nixpkgs-fmt" ];
}
