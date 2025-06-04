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
  cfg = config.croissant.programs.fd;
in
{
  _file = ./fd.nix;

  options.croissant.programs = {
    fd = {
      configure = mkEnableOption "set up fd";
    };
  };

  config = lib.mkMerge [
    {
      programs.fd.enable = true;
    }
    (lib.mkIf cfg.configure {
      home = {
        shellAliases = {
          fdA = "fd --hidden --no-ignore";
          fda = "fd --hidden";
        };
      };
    })
  ];
}
