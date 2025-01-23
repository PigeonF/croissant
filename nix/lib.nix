# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  extraNixOsModules ? [ ],
  home-manager-lib,
  lib,
  nix-darwin-lib,
}:
let
  croissant-lib = {
    microVMToApp = configuration: {
      type = "app";
      program = "${configuration.config.microvm.declaredRunner}/bin/microvm-run";
    };
    mkDarwinConfiguration =
      args@{
        croissantNixOsPresetsPath ? ./modules/nixos/presets,
        specialArgs ? { },
        ...
      }:
      nix-darwin-lib.darwinSystem (
        {
          specialArgs = {
            inherit croissantNixOsPresetsPath;
          } // args.specialArgs;
        }
        // builtins.removeAttrs args [
          "croissantNixOsPresetsPath"
          "specialArgs"
        ]
      );
    mkHomeConfiguration =
      args@{
        croissantPresetsPath ? ./modules/home/presets,
        extraSpecialArgs ? { },
        ...
      }:
      home-manager-lib.homeManagerConfiguration (
        {
          extraSpecialArgs = {
            inherit croissantPresetsPath;
          } // args.extraSpecialArgs;
        }
        // builtins.removeAttrs args [
          "croissantPresetsPath"
          "extraSpecialArgs"
        ]
      );
    mkNixOsConfiguration =
      args@{
        croissantPresetsPath ? ./modules/nixos/presets,
        specialArgs ? { },
        modules ? [ ],
        ...
      }:
      lib.nixosSystem (
        {
          modules = extraNixOsModules ++ args.modules;
          specialArgs = {
            inherit croissantPresetsPath;
          } // args.specialArgs;
        }
        // builtins.removeAttrs args [
          "croissantPresetsPath"
          "modules"
          "specialArgs"
        ]
      );
  };
in
croissant-lib
