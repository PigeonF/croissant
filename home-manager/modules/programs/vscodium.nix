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
in
{
  _file = ./vscodium.nix;

  options.croissant.programs = {
    vscodium = {
      configure = mkEnableOption "set up vscodium";

      extensions = mkOption {
        default = [
          pkgs.vscode-extensions.bierner.emojisense
          pkgs.vscode-extensions.bierner.github-markdown-preview
          pkgs.vscode-extensions.bierner.markdown-checkbox
          pkgs.vscode-extensions.bierner.markdown-emoji
          pkgs.vscode-extensions.bierner.markdown-footnotes
          pkgs.vscode-extensions.bierner.markdown-mermaid
          pkgs.vscode-extensions.bierner.markdown-preview-github-styles
          pkgs.vscode-extensions.catppuccin.catppuccin-vsc
          pkgs.vscode-extensions.catppuccin.catppuccin-vsc-icons
          pkgs.vscode-extensions.editorconfig.editorconfig
          pkgs.vscode-extensions.nefrob.vscode-just-syntax
          pkgs.vscode-extensions.redhat.vscode-yaml
          pkgs.vscode-extensions.rust-lang.rust-analyzer
          pkgs.vscode-extensions.tamasfe.even-better-toml
        ];
        example = lib.literalExpression ''
          [
            pkgs.vscode-extensions.rust-lang.rust-analyzer
          ]
        '';
        type = types.listOf types.package;
        description = ''
          Extensions to install for vscodium.
        '';
      };

      extraPackages = mkOption {
        default = [
          pkgs.recursive
        ];
        example = lib.literalExpression ''
          [
            pkgs.ripgrep
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
    # {
    #   fonts = {
    #     fontconfig = {
    #       enable = true;
    #     };
    #   };

    #   home = {
    #     packages = cfg.extraPackages;
    #   };

    #   programs = {
    #     vscode = {
    #       enable = true;
    #       package = pkgs.vscodium;
    #     };
    #   };
    # }
    # (lib.mkIf cfg.configure {
    #   programs = {
    #     vscode = {
    #       profiles = {
    #         default = {
    #           inherit (cfg) extensions;
    #         };
    #       };
    #     };
    #   };
    # })
  ];
}
