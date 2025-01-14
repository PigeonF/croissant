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
  deploySystem = "x86_64-linux";
  deployLib = inputs.deploy-rs.lib.${deploySystem};
in
{
  _file = ./default.nix;

  deploy-rs.nodes.serenno = {
    hostname = "serenno.incus";
    profilesOrder = [
      "system"
      "root"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.nixos self.nixosConfigurations.serenno;
      };
      root = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.home-manager inputs.self.legacyPackages.${system}.homeConfigurations.root;
      };
    };
  };

  flake = {
    nixosConfigurations = {
      serenno = croissant-lib.mkNixOsConfiguration {
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
      serenno = self.nixosConfigurations.serenno.config.system.build.toplevel;
    };
  };
}
