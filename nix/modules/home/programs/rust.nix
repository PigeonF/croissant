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
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.rust;
in
{
  _file = ./rust.nix;

  options.croissant.programs = {
    rust = {
      enable = mkEnableOption "set up rust";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          cargo-audit
          cargo-binstall
          cargo-bloat
          cargo-deny
          cargo-fuzz
          cargo-hack
          cargo-nextest
          cargo-show-asm
          rustup
          ;
      };
    };
  };
}
