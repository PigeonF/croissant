{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.yazi;
in
{
  _file = ./yazi.nix;

  options.croissant.programs = {
    yazi = {
      enable = mkEnableOption "set up yazi";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        yazi = {
          inherit (cfg) enable;
        };
      };
    }
  ];
}
