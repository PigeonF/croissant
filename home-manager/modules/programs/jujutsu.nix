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
    mkOption
    types
    ;
  cfg = config.croissant.programs.jujutsu;
in
{
  _file = ./jujutsu.nix;

  options.croissant.programs = {
    jujutsu = {
      configure = mkEnableOption "set up jujutsu";

      extraPackages = mkOption {
        default = [
          pkgs.git
          pkgs.watchman
        ];
        example = lib.literalExpression ''
          [
            pkgs.delta
          ]
        '';
        type = types.listOf types.package;
        description = ''
          Extra packages that should be installed to the home profile.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      programs.jujutsu.enable = true;
      home.packages = cfg.extraPackages;
    }
    (lib.mkIf cfg.configure {
      home = {
        shellAliases = {
          jjj = "jj --ignore-working-copy";
        };
      };
    })
  ];
}
