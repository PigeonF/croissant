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
    mkOption
    types
    ;
  cfg = config.croissant.programs.helix;
in
{
  _file = ./helix.nix;

  options.croissant.programs = {
    helix = {
      extraPackages = mkOption {
        default = [
          pkgs.marksman
          pkgs.nil
          pkgs.nixfmt-rfc-style
          pkgs.nodePackages_latest.vscode-json-languageserver
          pkgs.taplo
          pkgs.tinymist
          pkgs.typescript-language-server
          pkgs.vscode-langservers-extracted
          pkgs.yaml-language-server
        ];
        example = lib.literalExpression ''
          [
            pkgs.yaml-language-server
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
      home = {
        packages = cfg.extraPackages;
      };

      programs = {
        helix = {
          enable = true;
          defaultEditor = lib.mkDefault true;
        };
      };
    }
  ];
}
