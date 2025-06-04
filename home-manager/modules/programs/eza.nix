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
  cfg = config.croissant.programs.eza;
in
{
  _file = ./eza.nix;

  options.croissant.programs = {
    eza = {
      configure = mkEnableOption "set up eza";
    };
  };

  config = lib.mkMerge [
    {
      programs.eza.enable = true;
    }
    (lib.mkIf cfg.configure {
      home = {
        shellAliases = {
          la = "eza --long --all";
          ls = "eza";
        };
      };
    })
  ];
}
