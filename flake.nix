# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  description = "Yummy nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default?ref=main";
    flake-compat.url = "github:edolstra/flake-compat?ref=master";
    flake-parts = {
      url = "github:hercules-ci/flake-parts?ref=main";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      systems,
      flake-parts,
      treefmt-nix,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      _file = ./flake.nix;

      systems = import systems;

      imports = [
        treefmt-nix.flakeModule
      ];

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
            treefmt = config.treefmt.build.devShell;
            default = pkgs.mkShellNoCC {
              name = "croissant";
              inputsFrom = builtins.attrValues (builtins.removeAttrs self'.devShells [ "default" ]);
            };
          };
        };
    });
}
