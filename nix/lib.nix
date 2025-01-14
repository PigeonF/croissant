# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
}:
let
  croissant-lib = {
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
