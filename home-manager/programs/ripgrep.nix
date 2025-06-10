{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.ripgrep;
in
{
  _file = ./ripgrep.nix;

  options.croissant.programs = {
    ripgrep = {
      enable = mkEnableOption "set up ripgrep";
    };
  };

  config = lib.mkMerge [
    {
      programs.ripgrep = {
        inherit (cfg) enable;
      };
    }
    (lib.mkIf cfg.enable {
      home = {
        shellAliases = {
          rgA = "rg --hidden --no-ignore";
          rga = "rg --hidden";
        };
      };
    })
  ];
}
