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
  cfg = config.croissant.programs.starship;
in
{
  _file = ./starship.nix;

  options.croissant.programs = {
    starship = {
      enable = mkEnableOption "set up starship";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      starship = {
        enable = lib.mkDefault true;
      };
    };
  };
}
