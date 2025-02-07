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
  cfg = config.croissant.programs.zellij;
in
{
  _file = ./zellij.nix;

  options.croissant.programs = {
    zellij = {
      enable = mkEnableOption "set up zellij";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      zellij = {
        enable = true;
        enableBashIntegration = false;
        enableFishIntegration = false;
        enableZshIntegration = false;
      };
    };
  };
}
