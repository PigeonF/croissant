# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  description = "Yummy nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=release-24.11";
    nix-darwin = {
      # url = "github:nix-darwin/nix-darwin?ref=master";
      url = "github:PigeonF/nix-darwin?ref=push-vlvowsnlollq";
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
    lix-modules = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=refs/tags/2.93.0";
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
        darwin-configurations = ./nix/modules/flake-parts/darwin-configurations.nix;
        deploy-rs = ./nix/modules/flake-parts/deploy-rs.nix;
        home-modules = ./nix/modules/flake-parts/home-modules.nix;
      };
      homeModules = {
        dotfiles = ./nix/modules/home/dotfiles.nix;
        programs-atuin = ./nix/modules/home/programs/atuin.nix;
        programs-bash = ./nix/modules/home/programs/bash.nix;
        programs-containers = ./nix/modules/home/programs/containers.nix;
        programs-ghq = ./nix/modules/home/programs/ghq.nix;
        programs-git = ./nix/modules/home/programs/git.nix;
        programs-helix = ./nix/modules/home/programs/helix.nix;
        programs-jujutsu = ./nix/modules/home/programs/jujutsu.nix;
        programs-nushell = ./nix/modules/home/programs/nushell.nix;
        programs-rust = ./nix/modules/home/programs/rust.nix;
        programs-starship = ./nix/modules/home/programs/starship.nix;
        programs-vscodium = ./nix/modules/home/programs/vscodium.nix;
        programs-yazi = ./nix/modules/home/programs/yazi.nix;
        programs-zellij = ./nix/modules/home/programs/zellij.nix;
        programs-zsh = ./nix/modules/home/programs/zsh.nix;
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
      nixosModules = {
        disk = ./nix/modules/nixos/disk;
        microvm-host = ./nix/modules/nixos/microvm/host.nix;
        microvm-vm = ./nix/modules/nixos/microvm/vm.nix;
        microvms = ./nix/modules/nixos/microvms.nix;
      };
      overlays = import ./nix/overlays inputs;
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
          ./hosts/callisto
          ./hosts/ganymede
          ./hosts/oberon
          ./hosts/phoebe
          ./hosts/puck
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
            homeModules
            lib
            nixosModules
            overlays
            ;
        };

        perSystem =
          {
            self',
            inputs',
            config,
            pkgs,
            ...
          }:
          {
            _module.args.pkgs = inputs'.nixpkgs.legacyPackages.appendOverlays [
              overlays.default
            ];

            treefmt = import ./treefmt.nix;

            checks = {
              reuse =
                let
                  files = pkgs.nix-gitignore.gitignoreSourcePure [
                    ".jj/"
                    ".dotter/cache.toml"
                    ".dotter/cache/"
                    "*.gitignored.*"
                  ] (pkgs.lib.cleanSource ./.);
                in
                pkgs.runCommandLocal "reuse" { } ''
                  ${pkgs.lib.getExe pkgs.reuse} --root ${files} lint | tee $out
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
                packages = [
                  pkgs.age
                  pkgs.just
                  pkgs.mkpasswd
                  pkgs.nixos-anywhere
                  pkgs.openssh
                  pkgs.pwgen
                  pkgs.sops
                  pkgs.ssh-to-age
                  pkgs.yq-go
                ];
              };
              treefmt = config.treefmt.build.devShell;
            };

            packages = {
              inherit (pkgs) gitlab-runner;
            };
          };
      });
}
