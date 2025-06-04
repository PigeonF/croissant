# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  flake-parts-lib,
  moduleLocation,
  ...
}:
let
  inherit (lib)
    mapAttrs
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
    ;
in
{
  _file = ./flake-module.nix;

  options = {
    flake = mkSubmoduleOptions {
      darwinConfigurations = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = { };
        description = ''
          nix-darwin configurations.
        '';
      };

      darwinModules = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
        apply = mapAttrs (
          k: v: {
            _file = "${toString moduleLocation}#darwinModules.${k}";
            imports = [ v ];
          }
        );
        description = ''
          nix-darwin modules.

          You may use this for reusable pieces of configuration, service modules, etc.
        '';
      };
    };
  };
}
