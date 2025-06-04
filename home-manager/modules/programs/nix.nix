# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.nix;
in
{
  _file = ./nix.nix;

  options.croissant.programs = {
    nix = {
      configure = mkEnableOption "set up nix";
    };
  };

  config = lib.mkMerge [
    {
      nix = {
        package = pkgs.nixVersions.stable;
      };
    }
    (lib.mkIf cfg.configure {
      nix = {
        settings = {
          use-xdg-base-directories = true;
        };
      };
    })
  ];
}
