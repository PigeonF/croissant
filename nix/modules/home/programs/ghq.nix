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
  cfg = config.croissant.programs.ghq;
in
{
  _file = ./ghq.nix;

  options.croissant.programs = {
    ghq = {
      enable = mkEnableOption "set up ghq";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = [ pkgs.ghq ];
      sessionVariables = {
        GHQ_ROOT = "$HOME/git";
      };
    };
  };
}
