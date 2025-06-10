{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.zoxide;
in
{
  _file = ./zoxide.nix;

  options.croissant.programs = {
    zoxide = {
      enable = mkEnableOption "set up zoxide";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        zoxide = {
          inherit (cfg) enable;
        };
      };
    }
  ];
}
