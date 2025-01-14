# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  home-manager-lib,
  lib,
}:
let
  croissant-lib = {
    mkHomeConfiguration = home-manager-lib.homeManagerConfiguration;
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
