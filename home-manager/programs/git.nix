{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.croissant.programs.git;
in
{
  _file = ./git.nix;

  options.croissant.programs = {
    git = {
      enable = mkEnableOption "set up git";

      extraPackages = mkOption {
        default = [
          pkgs.delta
          pkgs.gnupg
        ];
        example = lib.literalExpression ''
          [
            pkgs.git-branchless
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
    (lib.mkIf cfg.enable {
      programs = {
        # Writes to ~/.config/git/config unconditionally, but we want to use our dotfiles instead.
        git.enable = false;
      };
      home = {
        packages = [ pkgs.git ];
      };
    })
    (lib.mkIf cfg.enable {
      home = {
        packages = cfg.extraPackages;

        shellAliases = {
          g = "git";
        };
      };
    })
  ];
}
