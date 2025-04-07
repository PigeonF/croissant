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
  cfg = config.croissant.programs.helix;
in
{
  _file = ./helix.nix;

  options.croissant.programs = {
    helix = {
      enable = mkEnableOption "set up helix";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          marksman
          nil
          nixfmt-rfc-style
          taplo
          tinymist
          typescript-language-server
          vscode-langservers-extracted
          yaml-language-server
          ;
        inherit (pkgs.nodePackages_latest)
          vscode-json-languageserver
          ;
      };
    };
    programs = {
      helix = {
        enable = true;
        defaultEditor = lib.mkDefault true;
      };
    };
  };
}
