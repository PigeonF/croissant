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
  system = "aarch64-linux";
  deploySystem = "aarch64-linux";
  deployLib = inputs.deploy-rs.lib.${deploySystem};
in
{
  _file = ./default.nix;

  deploy-rs.nodes.oberon = {
    hostname = "oberon";
    profilesOrder = [
      "system"
      "pigeonf"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.nixos self.nixosConfigurations.oberon;
      };
      pigeonf = {
        user = "pigeonf";
        sshUser = "pigeonf";
        path =
          deployLib.activate.home-manager
            inputs.self.legacyPackages.${system}.homeConfigurations.pigeonf;
      };
    };
  };

  flake = {
    nixosConfigurations = {
      oberon = croissant-lib.mkNixOsConfiguration {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.home-manager.nixosModules.home-manager
          inputs.lix-modules.nixosModules.default
          inputs.sops-nix.nixosModules.sops
          ./disks.nix
          ./networking.nix
          ./nix.nix
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
      oberon = self.nixosConfigurations.oberon.config.system.build.toplevel;
    };
  };
}
