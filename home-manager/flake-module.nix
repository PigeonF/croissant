# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, ... }:
      {
        _file = ./flake-module.nix;
        options = {
          homeConfigurations = mkOption {
            type = types.lazyAttrsOf types.raw;
            default = { };
            description = ''
              home-manager modules.

              You may use this for reusable pieces of configuration, users, etc.
            '';
          };
        };

        config = {
          legacyPackages = {
            inherit (config) homeConfigurations;
          };
        };
      }
    );
  };
}
