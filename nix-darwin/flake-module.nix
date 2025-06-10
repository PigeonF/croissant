# flake-parts module for combining multiple nix-darwin configurations and modules.
{
  flake-parts-lib,
  lib,
  moduleLocation,
  ...
}:
let
  inherit (lib)
    literalExpression
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
          Insantiated nix-darwin configurations. Used by `darwin-rebuild`.

          `darwinConfigurations` is for specific machines. To expose reusable configurations, add
          them to [`darwinModules`](#opt-flake.darwinModules) in the form of modules.
        '';
        example = literalExpression ''
          {
            my-machine = inputs.nix-darwin.lib.darwinSystem {
              system = "aarch64-darwin";

              modules = [
                ./my-machine/nix-darwin-configuration.nix
                config.darwinModules.my-module
              ];
            };
          }
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
