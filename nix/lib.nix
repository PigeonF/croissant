# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  home-manager-lib,
  lib,
}:
let
  croissant-lib = {
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
        ...
      }:
      lib.nixosSystem (
        {
          specialArgs = {
            inherit croissantPresetsPath;
          } // args.specialArgs;
        }
        // builtins.removeAttrs args [
          "croissantPresetsPath"
          "specialArgs"
        ]
      );
  };
in
croissant-lib
