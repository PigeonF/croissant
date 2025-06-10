{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.home-manager;
in
{
  _file = ./home-manager.nix;

  options.croissant.programs = {
    home-manager = {
      enable = mkEnableOption "set up home-manager";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        home-manager = {
          inherit (cfg) enable;
        };
      };
    }
  ];
}
