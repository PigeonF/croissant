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
  cfg = config.croissant.programs.ripgrep;
in
{
  _file = ./ripgrep.nix;

  options.croissant.programs = {
    ripgrep = {
      configure = mkEnableOption "set up ripgrep";
    };
  };

  config = lib.mkMerge [
    {
      programs.ripgrep.enable = true;
    }
    (lib.mkIf cfg.configure {
      home = {
        shellAliases = {
          rgA = "rg --hidden --no-ignore";
          rga = "rg --hidden";
        };
      };
    })
  ];
}
