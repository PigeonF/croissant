# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.containers;
in
{
  _file = ./containers.nix;

  options.croissant.programs = {
    containers = {
      enable = mkEnableOption "set up container development";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          crane
          diffoci
          diffoscopeMinimal
          dive
          ;
      };
    };
  };
}
