# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  self,
  croissant-lib,
  ...
}:
let
  system = "x86_64-linux";
in
{
  _file = ./default.nix;

  flake = {
    nixosConfigurations = {
      raxus = croissant-lib.mkNixOsConfiguration {
        inherit system;

        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };

  perSystem = {
    apps = {
      raxus = croissant-lib.microVMToApp self.nixosConfigurations.raxus;
    };
    packages = {
      raxus = self.nixosConfigurations.raxus.config.system.build.toplevel;
    };
  };
}
