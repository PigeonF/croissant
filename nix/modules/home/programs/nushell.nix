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
  cfg = config.croissant.programs.nushell;
in
{
  _file = ./nushell.nix;

  options.croissant.programs = {
    nushell = {
      enable = mkEnableOption "set up nushell";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      nushell = {
        enable = true;
      };
    };
  };
}
