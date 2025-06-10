{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.croissant.homebrew;
in
{
  _file = ./homebrew.nix;

  options = {
    croissant.homebrew = {
      enable = mkEnableOption "the homebrew configuration";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPath = [ "${config.homebrew.brewPrefix}" ];
    };

    homebrew = {
      enable = true;
    };
  };
}
