{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.eza;
in
{
  _file = ./eza.nix;

  options.croissant.programs = {
    eza = {
      enable = mkEnableOption "set up eza";
    };
  };

  config = lib.mkMerge [
    {
      programs.eza = {
        inherit (cfg) enable;
      };
    }
    (lib.mkIf cfg.enable {
      home = {
        shellAliases = {
          la = "eza --long --all";
          ls = "eza";
        };
      };
    })
  ];
}
