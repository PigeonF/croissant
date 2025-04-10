# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  croissant-lib,
  ...
}:
let
  system = "aarch64-darwin";
  deploySystem = "aarch64-darwin";
  deployLib = inputs.deploy-rs.lib.${deploySystem};

  phoebe = croissant-lib.mkDarwinConfiguration {
    inherit system;
    specialArgs = {
      inherit inputs;
    };
    modules = [
      inputs.lix-modules.nixosModules.default
      ./homebrew.nix
      ./nix.nix
      ./system.nix
      ./users.nix
      ./xdg.nix
    ];
  };
in
{
  _file = ./default.nix;

  deploy-rs.nodes.phoebe = {
    hostname = "phoebe";
    profilesOrder = [
      "system"
      "root"
      "pigeonf"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "pigeonf";
        path = deployLib.activate.darwin phoebe;
      };
      root = {
        user = "root";
        sudo = "sudo --login -u";
        sshUser = "pigeonf";
        path = deployLib.activate.home-manager inputs.self.legacyPackages.${system}.homeConfigurations.root;
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
    darwinConfigurations = {
      inherit phoebe;
    };
  };

  perSystem = {
    packages = {
      phoebe = phoebe.config.system.build.toplevel;
    };
  };
}
