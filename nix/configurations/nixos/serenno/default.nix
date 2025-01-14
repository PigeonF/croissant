# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ inputs, ... }:
{
  _file = ./default.nix;

  flake = {
    nixosConfigurations = {
      serenno =
        let
          system = "x86_64-linux";
        in
        inputs.nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = { inherit inputs system; };
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
          ];
        };
    };
  };

  perSystem = {
    packages = {
      serenno = inputs.self.nixosConfigurations.serenno.config.system.build.toplevel;
    };
  };
}
