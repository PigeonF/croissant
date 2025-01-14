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
      lib = import ./nix/lib.nix {
        inherit (nixpkgs) lib;
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
          ./nix/configurations/nixos/serenno
          treefmt-nix.flakeModule
        ] ++ builtins.attrValues flakeModules;

        flake = {
          inherit flakeModules lib;
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
