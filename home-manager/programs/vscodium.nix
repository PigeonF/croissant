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
  cfg = config.croissant.programs.vscodium;
in
{
  _file = ./vscodium.nix;

  options.croissant.programs = {
    vscodium = {
      enable = mkEnableOption "set up vscodium";

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
    {
      programs.vscode = {
        # inherit (cfg) enable;
        # mkdir: cannot create directory '/nix/store/fpv2mlmsyzfh255q0bhnfnz77fi4kj89-vscodium-1.100.13210/Applications/VSCodium.app': Operation not permitted
        enable = false;
        package = pkgs.vscodium;
        profiles = {
          default = {
            inherit (cfg) extensions;
          };
        };
      };
    }
    (lib.mkIf cfg.enable {
      fonts = {
        fontconfig = {
          enable = true;
        };
      };

      home = {
        packages = cfg.extraPackages;
      };
    })
  ];
}
