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
  cfg = config.croissant.programs.yazi;
in
{
  _file = ./yazi.nix;

  options.croissant.programs = {
    yazi = {
      enable = mkEnableOption "set up yazi";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      yazi = {
        enable = true;
      };
    };
  };
}
