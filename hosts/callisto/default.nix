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

  deploy-rs.nodes.callisto = {
    hostname = "callisto";
    profilesOrder = [
      "system"
      "pigeonf"
    ];

    profiles = {
      system = {
        user = "root";
        path = deployLib.activate.darwin self.darwinConfigurations.callisto;
      };
      pigeonf = {
        user = "pigeonf";
        path =
          deployLib.activate.home-manager
            inputs.self.legacyPackages.${system}.homeConfigurations.pigeonf;
      };
    };
  };

  flake = {
    darwinConfigurations = {
      callisto = croissant-lib.mkDarwinConfiguration {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.lix-modules.nixosModules.default
          ./homebrew.nix
          ./nix.nix
          ./system.nix
          ./users.nix
          ./xdg.nix
        ];
      };

      callisto-bootstrap = croissant-lib.mkDarwinConfiguration {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.lix-modules.nixosModules.default
          ./system.nix
          (_: {
            config = {
              launchd = {
                daemons = {
                  linux-builder = {
                    serviceConfig = {
                      StandardOutPath = "/var/log/darwin-builder.log";
                      StandardErrorPath = "/var/log/darwin-builder.log";
                    };
                  };
                };
              };
              nix = {
                linux-builder = {
                  enable = true;
                };
                settings = {
                  extra-experimental-features = [
                    "flakes"
                    "nix-command"
                  ];
                  trusted-users = [
                    "@admin"
                  ];
                };
              };
            };
          })
        ];
      };
    };
  };

  perSystem = {
    packages = {
      callisto = self.darwinConfigurations.callisto.config.system.build.toplevel;
      callisto-bootstrap = self.darwinConfigurations.callisto-bootstrap.config.system.build.toplevel;
    };
  };
}
