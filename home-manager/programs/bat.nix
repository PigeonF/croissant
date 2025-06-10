{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.bat;
in
{
  _file = ./bat.nix;

  options.croissant.programs = {
    bat = {
      enable = mkEnableOption "set up bat";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        bat = {
          inherit (cfg) enable;
        };
      };
    }
  ];
}
