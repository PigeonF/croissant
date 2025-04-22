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

  deploy-rs.nodes.puck = {
    hostname = "puck";
    profilesOrder = [
      "system"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.nixos self.nixosConfigurations.puck;
      };
    };
  };

  flake = {
    nixosConfigurations = {
      puck = croissant-lib.mkNixOsConfiguration {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          ./disks.nix
          ./networking.nix
          ./nix.nix
          ./services.nix
          ./system.nix
          ./users.nix
          ./virtualization.nix
          ./xdg.nix
        ];
      };
    };
  };

  perSystem = {
    packages = {
      puck = self.nixosConfigurations.puck.config.system.build.toplevel;
    };
  };
}
