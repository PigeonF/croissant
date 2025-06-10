{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.atuin;
in
{
  _file = ./atuin.nix;

  options.croissant.programs = {
    atuin = {
      enable = mkEnableOption "set up atuin";
    };
  };

  config = lib.mkMerge [
    {
      programs.atuin = {
        inherit (cfg) enable;
        flags = [ "--disable-up-arrow" ];
        settings = {
          history_filter = [
            "^[bc]at"
            "^cd"
            "^exit"
            "^export [0-9a-zA-Z\\-_]+?[-_]TOKEN="
            "^ls"
            "glpat-[0-9a-zA-Z\\-_]{20}"
          ];
        };
      };
    }
  ];
}
