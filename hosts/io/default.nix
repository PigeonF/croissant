# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  deploy-rs-lib,
  croissant-lib,
  inputs,
  withSystem,
  lib,
  ...
}:
let
  io = lib.nixosSystem {
    system = "aarch64-linux";

    specialArgs = {
      inherit inputs;
    };

    modules = [
      ./io.nix
    ];
  };
in
{
  _file = ./default.nix;

  flake = {
    nixosConfigurations = {
      inherit io;
    };
  };

  perSystem =
    { pkgs, ... }:
    let
      root = croissant-lib.mkHomeManagerConfiguration {
        inherit pkgs;

        modules = [ ./root.nix ];
      };
    in
    {
      homeConfigurations = {
        "io.root" = root;
      };

      packages = {
        io = io.config.system.build.toplevel;
        ioImage = io.config.formats.qcow-efi;
      };
    };

  deploy-rs.nodes.io = withSystem io.config.nixpkgs.system (
    { config, ... }:
    {
      hostname = "io.fritz.box";
      profilesOrder = [
        "system"
        "root"
      ];
      profiles =
        let
          deploy-lib = deploy-rs-lib."aarch64-darwin";
        in
        {
          system = {
            sshUser = "root";
            path = deploy-lib.activate.nixos io;
          };
          root = {
            sshUser = "root";
            path = deploy-lib.activate.home-manager config.homeConfigurations."io.root";
          };
        };
    }
  );
}
