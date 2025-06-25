# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  description = "Yummy nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=refs/heads/release-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=refs/heads/nixpkgs-unstable";
    nix-darwin = {
      # url = "github:nix-darwin/nix-darwin?ref=refs/heads/nix-darwin-25.05";
      url = "github:PigeonF/nix-darwin?ref=refs/heads/push-vlvowsnlollq";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default?ref=refs/heads/main";
    flake-parts = {
      url = "github:hercules-ci/flake-parts?ref=refs/heads/main";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils?ref=refs/heads/main";
      inputs.systems.follows = "systems";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs?ref=refs/heads/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    disko = {
      url = "github:nix-community/disko?ref=refs/heads/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=refs/heads/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence?ref=refs/heads/master";
    };
    lix-modules = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=refs/heads/release-2.93";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    microvm = {
      url = "github:astro/microvm.nix?ref=refs/heads/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder?ref=refs/heads/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixos-generators.follows = "nixos-generators";
    };
    nixos-facter-modules = {
      url = "github:numtide/nixos-facter-modules?ref=refs/heads/main";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators?ref=refs/heads/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-lima = {
      url = "github:nixos-lima/nixos-lima?ref=refs/heads/master";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixos-generators.follows = "nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix?ref=refs/heads/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix?ref=refs/heads/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      deploy-rs,
      flake-parts,
      home-manager,
      nix-darwin,
      nixpkgs,
      self,
      systems,
      treefmt-nix,
      ...
    }:
    let
      nix-darwin-lib = nix-darwin.lib;
      home-manager-lib = home-manager.lib;
      nixpkgs-lib = nixpkgs.lib;
      lib =
        { }
        // import ./home-manager/lib.nix {
          inherit inputs home-manager-lib;
        }
        // import ./nix-darwin/lib.nix {
          inherit inputs nix-darwin-lib;
        }
        // import ./nixos/lib.nix {
          inherit inputs nixpkgs-lib;
        };
      flakeModules = {
        default = {
          imports = [
            ./hosts/flake-module.nix
            ./nix-darwin/flake-module.nix
          ];
        };
      };
    in
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs = {
          deploy-rs-lib = deploy-rs.lib;
          inherit home-manager-lib nix-darwin-lib;
          croissant-lib = lib;
        };
      }
      (_: {
        _file = ./flake.nix;

        systems = import systems;

        imports = [
          ./home-manager
          ./hosts
          ./nix-darwin
          ./nixpkgs
          ./nixos
          flake-parts.flakeModules.flakeModules
          home-manager.flakeModules.home-manager
          treefmt-nix.flakeModule
        ];

        flake = {
          inherit
            flakeModules
            lib
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
              self.overlays.default
            ];

            treefmt = import ./treefmt.nix;

            checks = {
              reuse =
                let
                  files = pkgs.nix-gitignore.gitignoreSourcePure [ ] (pkgs.lib.cleanSource ./.);
                in
                pkgs.runCommandLocal "reuse" { } ''
                  ${pkgs.lib.getExe pkgs.reuse} --root ${files} lint | tee $out
                '';
            };

            devShells = {
              default = pkgs.mkShellNoCC {
                name = "croissant";
                inputsFrom = builtins.attrValues (builtins.removeAttrs self'.devShells [ "default" ]);

                packages = [
                  pkgs.git
                  pkgs.jujutsu
                ];
              };
              treefmt = config.treefmt.build.devShell;
            };
          };
      });
}
