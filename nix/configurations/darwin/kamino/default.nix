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
  system = "aarch64-darwin";
  deploySystem = "aarch64-darwin";
  deployLib = inputs.deploy-rs.lib.${deploySystem};
in
{
  _file = ./default.nix;

  deploy-rs.nodes.kamino = {
    hostname = "kamino.local";
    profilesOrder = [
      "system"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "pigeonf";
        path = deployLib.activate.darwin self.darwinConfigurations.kamino;
      };
    };
  };

  flake = {
    darwinConfigurations = {
      kamino = croissant-lib.mkDarwinConfiguration {
        inherit system;

        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };

  perSystem = {
    packages = {
      kamino = self.darwinConfigurations.kamino.config.system.build.toplevel;
    };
  };
}
