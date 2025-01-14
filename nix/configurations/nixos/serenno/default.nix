# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ inputs, ... }:
let
  system = "x86_64-linux";
  deploySystem = "x86_64-linux";
  deployLib = inputs.deploy-rs.lib.${deploySystem};
in
{
  _file = ./default.nix;

  deploy-rs.nodes.serenno = {
    hostname = "serenno.incus";
    profiles = {
      system = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.nixos inputs.self.nixosConfigurations.serenno;
      };
    };
  };

  flake = {
    nixosConfigurations = {
      serenno = inputs.nixpkgs.lib.nixosSystem {
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
