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
  cfg = config.croissant.programs.helix;
in
{
  _file = ./helix.nix;

  options.croissant.programs = {
    helix = {
      enable = mkEnableOption "set up helix";

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
      programs = {
        helix = {
          inherit (cfg) enable;
          defaultEditor = lib.mkDefault true;
        };
      };
    }
    (lib.mkIf cfg.enable {
      home = {
        packages = cfg.extraPackages;
      };
    })
  ];
}
