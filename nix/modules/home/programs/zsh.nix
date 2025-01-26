# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.zsh;
in
{
  _file = ./zsh.nix;

  options.croissant.programs = {
    zsh = {
      enable = mkEnableOption "set up zsh";
    };
  };

  # TERM
  # ripgrep / fd / ...
  # aliases

  config = lib.mkIf cfg.enable {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          eza
          fd
          ncurses
          ripgrep
          ;
      };
    };
    programs = {
      zsh = {
        enable = true;
        dotDir = ".config/zsh";
        defaultKeymap = "emacs";
        history = {
          path = "${config.xdg.dataHome}/zsh/zsh_history";
        };
        initExtraBeforeCompInit = ''
          bindkey "^[[1;5C" forward-word
          bindkey "^[[1;5D" backward-word
        '';
        shellAliases = {
          fdA = "fd --hidden --no-ignore";
          fda = "fd --hidden";
          la = "ls -la";
          ls = "eza";
          rgA = "rg --hidden --no-ignore";
          rga = "rg --hidden";
          wget = "wget --hsts-file=${config.xdg.dataHome}/wget-hsts";
        };
      };
    };
  };
}
