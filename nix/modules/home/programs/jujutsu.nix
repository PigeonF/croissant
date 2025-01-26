# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  inputs,
  lib,
  system,
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
        default = inputs.jujutsu.packages.${system}.jujutsu;
        defaultText = literalExpression "inputs.jujutsu.packages.\${system}.jujutsu";
        example = literalExpression "pkgs.jujutsu";
        description = "The package to use for jujutsu.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      jujutsu = {
        enable = true;
        package = lib.mkDefault cfg.package;
      };

      zsh.shellAliases = {
        jjj = "jj --ignore-working-copy";
      };
    };
  };
}
