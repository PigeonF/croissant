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
    mkOption
    types
    ;
  cfg = config.croissant.programs.git;
in
{
  _file = ./git.nix;

  options.croissant.programs = {
    git = {
      configure = mkEnableOption "set up git";

      extraPackages = mkOption {
        default = [
          pkgs.delta
          pkgs.gnupg
        ];
        example = lib.literalExpression ''
          [
            pkgs.git-branchless
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
      programs = {
        git.enable = false; # Writes to ~/.config/git/config unconditionally.
      };
      home = {
        packages = [ pkgs.git ] ++ cfg.extraPackages;
      };
    }
    (lib.mkIf cfg.configure {
      home = {
        shellAliases = {
          g = "git";
        };
      };
    })
  ];
}
