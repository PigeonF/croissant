{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.croissant.programs.jujutsu;
in
{
  _file = ./jujutsu.nix;

  options.croissant.programs = {
    jujutsu = {
      enable = mkEnableOption "set up jujutsu";

      extraPackages = mkOption {
        default = [
          pkgs.git
          pkgs.watchman
        ];
        example = lib.literalExpression ''
          [
            pkgs.delta
          ]
        '';
        type = types.listOf types.package;
        description = ''
          Extra packages that should be installed to the home profile.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      programs.jujutsu = {
        package = pkgs.masterPackages.jujutsu;
        inherit (cfg) enable;
      };
    }
    (lib.mkIf cfg.enable {
      home = {
        packages = cfg.extraPackages;

        shellAliases = {
          jjj = "jj --ignore-working-copy";
        };
      };
    })
  ];
}
