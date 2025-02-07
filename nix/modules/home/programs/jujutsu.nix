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
    literalExpression
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
      enable = mkEnableOption "set up jujutsu";
      package = mkOption {
        type = types.package;
        default = pkgs.jujutsu;
        example = literalExpression "inputs.jujutsu.packages.\${system}.jujutsu";
        description = "The package to use for jujutsu.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = builtins.attrValues { inherit (pkgs) watchman; };

      shellAliases = {
        jjj = "jj --ignore-working-copy";
      };
    };
    programs = {
      jujutsu = {
        enable = true;
        package = lib.mkDefault cfg.package;
      };
    };
  };
}
