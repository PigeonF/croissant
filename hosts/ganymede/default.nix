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

  deploy-rs.nodes.ganymede = {
    hostname = "ganymede";
    profilesOrder = [
      "system"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.nixos self.nixosConfigurations.ganymede;
      };
    };
  };

  flake = {
    nixosConfigurations = {
      ganymede = croissant-lib.mkNixOsConfiguration {
        inherit system;

        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.impermanence.nixosModules.impermanence
          inputs.lix-modules.nixosModules.default
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.sops-nix.nixosModules.sops
          ./disks.nix
          ./networking.nix
          ./nix.nix
          ./system.nix
          ./users.nix
          ./xdg.nix
        ];
      };
    };
  };

  perSystem = {
    packages = {
      ganymede = self.nixosConfigurations.ganymede.config.system.build.toplevel;
    };
  };
}
