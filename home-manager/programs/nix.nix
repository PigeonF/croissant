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
  cfg = config.croissant.programs.nix;
in
{
  _file = ./nix.nix;

  options.croissant.programs = {
    nix = {
      enable = mkEnableOption "set up nix";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      nix = {
        package = lib.mkDefault pkgs.nix;
        settings = {
          use-xdg-base-directories = true;
        };
      };
    })
  ];
}
