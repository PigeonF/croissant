# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
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

  config = lib.mkIf cfg.enable {
    home = {
      activation = {
        sourceZshFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -s "$HOME/.zshenv" ]; then
            run echo 'source "$HOME"/${
              lib.escapeShellArg config.home.file.".zshenv".target
            }' > "$HOME/.zshenv"
          fi
        '';
      };

      file = {
        ".zshenv" = {
          target = ".config/zsh/zshenv";
        };
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
      };
    };
  };
}
