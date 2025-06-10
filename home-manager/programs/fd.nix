{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.fd;
in
{
  _file = ./fd.nix;

  options.croissant.programs = {
    fd = {
      enable = mkEnableOption "set up fd";
    };
  };

  config = lib.mkMerge [
    {
      programs.fd = {
        inherit (cfg) enable;
      };
    }
    (lib.mkIf cfg.enable {
      home = {
        shellAliases = {
          fdA = "fd --hidden --no-ignore";
          fda = "fd --hidden";
        };
      };
    })
  ];
}
