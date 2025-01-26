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
  cfg = config.croissant.programs.helix;
in
{
  _file = ./helix.nix;

  options.croissant.programs = {
    helix = {
      enable = mkEnableOption "set up helix";
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      helix = {
        enable = lib.mkDefault true;
        defaultEditor = lib.mkDefault true;
      };
    };
  };
}
