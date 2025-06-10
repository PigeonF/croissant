{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.zellij;
in
{
  _file = ./zellij.nix;

  options.croissant.programs = {
    zellij = {
      enable = mkEnableOption "set up zellij";
    };
  };

  config = lib.mkMerge [
    {
      programs = {
        zellij = {
          inherit (cfg) enable;
          enableBashIntegration = false;
          enableFishIntegration = false;
          enableZshIntegration = false;
        };
      };
    }
  ];
}
