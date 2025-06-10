{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.starship;
in
{
  _file = ./starship.nix;

  options.croissant.programs = {
    starship = {
      enable = mkEnableOption "set up starship";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        starship = {
          inherit (cfg) enable;
        };
      };
    }
  ];
}
