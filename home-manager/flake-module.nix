# flake-parts module for combining multiple home-manager configurations and modules.
{
  flake-parts-lib,
  lib,
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
  _file = ./flake-module.nix;

  options = {
    perSystem = mkPerSystemOption (
      { config, ... }:
      {
        options = {
          homeConfigurations = mkOption {
            type = types.lazyAttrsOf types.raw;
            default = { };
            description = ''
              Instantiated Home Manager configurations.

              `homeConfigurations` is for specific installations. If you want to expose
              reusable configurations, add them to `flake.homeModules` in the form of modules,
              so that you can reference them in this or another flake's `homeConfigurations`.
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
