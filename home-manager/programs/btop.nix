{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.btop;
in
{
  _file = ./btop.nix;

  options.croissant.programs = {
    btop = {
      enable = mkEnableOption "set up btop";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        btop = {
          inherit (cfg) enable;
        };
      };
    }
  ];
}
