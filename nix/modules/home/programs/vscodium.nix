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
  cfg = config.croissant.programs.vscodium;
in
{
  _file = ./vscodium.nix;

  options.croissant.programs = {
    vscodium = {
      enable = mkEnableOption "set up vscodium";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      fontconfig = {
        enable = true;
      };
    };
    home = {
      packages = [ pkgs.recursive ];
    };
    programs = {
      vscode = {
        enable = true;
        package = pkgs.vscodium;
        profiles = {
          default = {
            extensions = builtins.attrValues {
              inherit (pkgs.vscode-extensions.bierner)
                emojisense
                github-markdown-preview
                markdown-checkbox
                markdown-emoji
                markdown-footnotes
                markdown-mermaid
                markdown-preview-github-styles
                ;
              inherit (pkgs.vscode-extensions.catppuccin) catppuccin-vsc catppuccin-vsc-icons;
              inherit (pkgs.vscode-extensions.editorconfig) editorconfig;
              inherit (pkgs.vscode-extensions.nefrob) vscode-just-syntax;
              inherit (pkgs.vscode-extensions.redhat) vscode-yaml;
              inherit (pkgs.vscode-extensions.rust-lang) rust-analyzer;
              inherit (pkgs.vscode-extensions.tamasfe) even-better-toml;
            };
          };
        };
      };
    };
  };
}
