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
  cfg = config.croissant.programs.bash;
in
{
  _file = ./bash.nix;

  options.croissant.programs = {
    bash = {
      enable = mkEnableOption "set up bash";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      activation = {
        sourceBashFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -s "$HOME/.bash_profile" ]; then
            run rm -f "$HOME/.bash_profile"
            run echo 'source "$HOME"/${
              lib.escapeShellArg config.home.file.".bash_profile".target
            }' > "$HOME/.bash_profile"
          fi
          if [ ! -s "$HOME/.profile" ]; then
            run rm -f "$HOME/.profile"
            run echo 'source "$HOME"/${
              lib.escapeShellArg config.home.file.".profile".target
            }' > "$HOME/.profile"
          fi
          if [ ! -s "$HOME/.bashrc" ]; then
            run rm -f "$HOME/.bashrc"
            run echo 'source "$HOME"/${
              lib.escapeShellArg config.home.file.".bashrc".target
            }' > "$HOME/.bashrc"
          fi
        '';
      };

      file = {
        ".bash_profile" = {
          target = ".config/bash/bash_profile";
        };
        ".profile" = {
          target = ".config/bash/profile";
        };
        ".bashrc" = {
          target = ".config/bash/bashrc";
        };
      };
    };

    programs = {
      bash = {
        enable = true;
        historyFile = "${config.xdg.dataHome}/bash/bash_history";
      };
    };
  };
}
