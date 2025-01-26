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
    programs = {
      bash = {
        enable = true;
        historyFile = "${config.xdg.dataHome}/bash/bash_history";
      };
    };
  };
}
