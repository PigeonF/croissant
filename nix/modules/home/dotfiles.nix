# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  cfg = config.croissant.dotfiles;
in
{
  _file = ./dotfiles.nix;

  options.croissant = {
    dotfiles = {
      enable = mkEnableOption "install the dotfiles";
      repo = mkOption {
        type = types.str;
        default = "https://github.com/PigeonF/croissant.git";
        description = ''
          Path to the dotfiles repository to clone.
        '';
      };
      dotter = lib.mkPackageOption pkgs "dotter" { };
      destination = mkOption {
        type = types.either types.str types.path;
        default = "${config.home.homeDirectory}/code/croissant";
        description = ''
          Directory to clone the dotfiles to.
        '';
      };
      dotterArgs = mkOption {
        type = types.listOf (types.either types.str types.path);
        default = [ ];
        description = ''
          Arguments to pass to `dotter`.
        '';
        example = [
          "--local-config"
          (pkgs.writeText "local.toml" ''
            packages = ["foo"]
          '')
        ];
      };
      useJujutsu = mkOption {
        type = types.bool;
        default = config.croissant.programs.jujutsu.enable;
        description = ''
          Whether to use `jj` to clone the repository.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      activation = {
        dotfiles =
          let
            clone =
              if cfg.useJujutsu then
                "${lib.getExe config.croissant.programs.jujutsu.package} git clone"
              else
                "${lib.getExe pkgs.git} clone";
          in
          lib.hm.dag.entryAfter [ "installPackages" ] ''
            if [ ! -d ${lib.escapeShellArg cfg.destination} ]; then
              run mkdir -p "$(dirname "${lib.escapeShellArg cfg.destination}")"
              run ${clone} ${lib.escapeShellArg cfg.repo} ${lib.escapeShellArg cfg.destination}
            else
              verboseEcho 'Dotfiles directory `' ${lib.escapeShellArg cfg.destination} '` exists already.'
            fi

            (cd ${lib.escapeShellArg cfg.destination}; ${lib.getExe cfg.dotter} $VERBOSE_ARG ''${DRY_RUN+--dry-run} --noconfirm ${lib.escapeShellArgs cfg.dotterArgs})
          '';
      };

      packages = [ cfg.dotter ];
    };
  };
}
