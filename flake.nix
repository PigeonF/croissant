# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  description = "Yummy nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin?ref=master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    jujutsu = {
      url = "github:jj-vcs/jj?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    lix-modules = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=2.92.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
        home-modules = ./nix/modules/flake-parts/home-modules.nix;
      };
      homeModules = {
        dotfiles = ./nix/modules/home/dotfiles.nix;
        programs-atuin = ./nix/modules/home/programs/atuin.nix;
        programs-bash = ./nix/modules/home/programs/bash.nix;
        programs-git = ./nix/modules/home/programs/git.nix;
        programs-helix = ./nix/modules/home/programs/helix.nix;
        programs-jujutsu = ./nix/modules/home/programs/jujutsu.nix;
        programs-starship = ./nix/modules/home/programs/starship.nix;
        programs-zellij = ./nix/modules/home/programs/zellij.nix;
        programs-zsh = ./nix/modules/home/programs/zsh.nix;
        shell = ./nix/modules/home/shell.nix;
      };
      nixosModules = {
        disk = ./nix/modules/nixos/disk;
        microvm-host = ./nix/modules/nixos/microvm/host.nix;
        microvm-vm = ./nix/modules/nixos/microvm/vm.nix;
        microvms = ./nix/modules/nixos/microvms.nix;
      };
      lib = import ./nix/lib.nix {
        extraHomeModules = builtins.attrValues homeModules;
        extraNixOsModules = builtins.attrValues (
          builtins.removeAttrs nixosModules [
            "microvm-host"
            "microvm-vm"
          ]
        );
        inherit (nixpkgs) lib;
        home-manager-lib = inputs.home-manager.lib;
        nix-darwin-lib = inputs.nix-darwin.lib;
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
          ./nix/configurations/darwin/kamino
          ./nix/configurations/home/pigeonf
          ./nix/configurations/home/root
          ./nix/configurations/microvm/raxus
          ./nix/configurations/nixos/serenno
          treefmt-nix.flakeModule
        ] ++ builtins.attrValues flakeModules;

        # https://github.com/serokell/deploy-rs/issues/216
        deploy-rs.flakeCheck = false;

        flake = {
          inherit
            flakeModules
            lib
            nixosModules
            homeModules
            ;
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

                packages = [ pkgs.git ];
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
