{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.nushell;
in
{
  _file = ./nushell.nix;

  options.croissant.programs = {
    nushell = {
      enable = mkEnableOption "set up nushell";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        nushell = {
          inherit (cfg) enable;
        };
      };
    }
  ];
}
