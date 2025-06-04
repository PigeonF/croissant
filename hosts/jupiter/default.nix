# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  deploy-rs-lib,
  home-manager-lib,
  inputs,
  nix-darwin-lib,
  withSystem,
  ...
}:
let
  jupiter = nix-darwin-lib.darwinSystem {
    system = "aarch64-darwin";

    specialArgs = {
      inherit inputs;
    };

    modules = [
      ./jupiter.nix
    ];
  };
in
{
  _file = ./default.nix;

  flake = {
    darwinConfigurations = {
      inherit jupiter;
    };
  };

  perSystem =
    { pkgs, system, ... }:
    let
      pigeonf = home-manager-lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs system;
        };

        modules = [ ./pigeonf.nix ];
      };
      root = home-manager-lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs system;
        };

        modules = [ ./root.nix ];
      };
    in
    {
      homeConfigurations = {
        "jupiter.pigeonf" = pigeonf;
        "jupiter.root" = root;
      };

      packages = {
        jupiter = jupiter.config.system.build.toplevel;
      };
    };

  deploy-rs.nodes.jupiter = withSystem jupiter.config.nixpkgs.system (
    { config, ... }:
    {
      hostname = "192.168.7.2";
      profilesOrder = [
        "system"
        "root"
        "pigeonf"
      ];
      profiles =
        let
          deploy-lib = deploy-rs-lib."aarch64-darwin";
        in
        {
          system = {
            sshUser = "root";
            path = deploy-lib.activate.darwin jupiter;
          };
          root = {
            sshUser = "root";
            path = deploy-lib.activate.home-manager config.homeConfigurations."jupiter.root";
          };
          pigeonf = {
            sshUser = "pigeonf";
            path = deploy-lib.activate.home-manager config.homeConfigurations."jupiter.pigeonf";
          };
        };
    }
  );
}
