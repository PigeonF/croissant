{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.ghq;
in
{
  _file = ./ghq.nix;

  options.croissant.programs = {
    ghq = {
      enable = mkEnableOption "set up ghq";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      home.packages = [ pkgs.ghq ];
    })
    (lib.mkIf cfg.enable {
      home = {
        sessionVariables = {
          GHQ_ROOT = "$HOME/git";
        };
      };
    })
  ];
}
