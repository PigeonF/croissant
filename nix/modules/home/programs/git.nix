# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
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
  cfg = config.croissant.programs.git;
in
{
  _file = ./git.nix;

  options.croissant.programs = {
    git = {
      enable = mkEnableOption "set up git";
      package = lib.mkPackageOption pkgs "git" { };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = builtins.attrValues {
      # Cannot use program.git because it unconditionally writes ~/.config/git/config.
      inherit (cfg) package;
      # Tools that are part of the git config
      inherit (pkgs)
        delta
        git-branchless
        gitlab-ci-local
        meld
        ;

      # General purpose tools
      inherit (pkgs) gh glab;
    };

    programs = {
      zsh.shellAliases = {
        g = "git";
      };
    };
  };
}
