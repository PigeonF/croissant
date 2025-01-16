# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  description = "Yummy nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default?ref=main";
    flake-compat = {
      url = "github:edolstra/flake-compat?ref=master";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts?ref=main";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils?ref=main";
      inputs.systems.follows = "systems";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.utils.follows = "flake-utils";
    };
    disko = {
      url = "github:nix-community/disko?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence?ref=master";
    };
    microvm = {
      url = "github:astro/microvm.nix?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules?ref=main";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      nixpkgs,
      systems,
      treefmt-nix,
      ...
    }:
    let
      flakeModules = {
        deploy-rs = ./nix/modules/flake-parts/deploy-rs.nix;
      };
      nixosModules = {
        disk = ./nix/modules/nixos/disk;
        microvm-host = ./nix/modules/nixos/microvm/host.nix;
        microvm-vm = ./nix/modules/nixos/microvm/vm.nix;
        microvms = ./nix/modules/nixos/microvms.nix;
      };
      lib = import ./nix/lib.nix {
        extraNixOsModules = builtins.attrValues (
          builtins.removeAttrs nixosModules [
            "microvm-host"
            "microvm-vm"
          ]
        );
        inherit (nixpkgs) lib;
        home-manager-lib = inputs.home-manager.lib;
      };
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          croissant-lib = lib;
        };
      }
      (_: {
        _file = ./flake.nix;

        systems = import systems;

        imports = [
          ./nix/configurations/home/root
          ./nix/configurations/microvm/raxus
          ./nix/configurations/nixos/serenno
          treefmt-nix.flakeModule
        ] ++ builtins.attrValues flakeModules;

        flake = {
          inherit flakeModules lib nixosModules;
        };

        perSystem =
          {
            self',
            config,
            pkgs,
            ...
          }:
          {
            treefmt = import ./treefmt.nix;

            checks = {
              reuse = pkgs.runCommandLocal "reuse" { } ''
                ${pkgs.lib.getExe pkgs.reuse} --root ${./.} lint | tee $out
              '';
            };

            devShells = {
              default = pkgs.mkShellNoCC {
                name = "croissant";
                inputsFrom = builtins.attrValues (builtins.removeAttrs self'.devShells [ "default" ]);
              };
              home-manager = pkgs.mkShellNoCC {
                name = "home-manager";
                packages = [
                  pkgs.home-manager
                  pkgs.nh
                ];
              };
              provisioning = pkgs.mkShellNoCC {
                name = "provisioning";
                inputsFrom = [ self'.devShells.secrets ];
                packages = [
                  pkgs.just
                  pkgs.nixos-anywhere
                  pkgs.openssh
                  pkgs.yq-go
                ];
              };
              secrets = pkgs.mkShellNoCC {
                name = "secrets";
                packages = [
                  pkgs.age
                  pkgs.ssh-to-age
                  pkgs.sops
                ];
              };
              treefmt = config.treefmt.build.devShell;
            };
          };
      });
}
