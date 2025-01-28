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
      mustafar = croissant-lib.mkNixOsConfiguration {
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
      mustafar = croissant-lib.microVMToApp self.nixosConfigurations.mustafar;
    };
    packages = {
      mustafar = self.nixosConfigurations.mustafar.config.system.build.toplevel;
    };
  };
}
