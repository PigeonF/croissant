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
  inherit (lib) literalExpression mkOption types;
in
{
  _file = ./shell.nix;

  options.croissant = {
    shell = {
      extraPackages = mkOption {
        default = builtins.attrValues {
          inherit (pkgs)
            eza
            fd
            ncurses
            ripgrep
            ;
        };
        description = ''
          Extra packages to add to the shell.
        '';
        type = types.listOf types.package;
      };
      aliases = mkOption {
        default = {
          fdA = "fd --hidden --no-ignore";
          fda = "fd --hidden";
          la = "ls -la";
          ls = "eza";
          rgA = "rg --hidden --no-ignore";
          rga = "rg --hidden";
          wget = "wget --hsts-file=${config.xdg.dataHome}/wget-hsts";
        };
        example = literalExpression ''
          {
            ll = "ls -l";
            ".." = "cd ..";
          }
        '';
        description = ''
          An attribute set that maps aliases (the top level attribute names in
          this option) to command strings or directly to build outputs.
        '';
        type = types.attrsOf types.str;
      };
    };
  };
}
