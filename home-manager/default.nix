# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  ...
}:
{
  _file = ./default.nix;

  imports = [
    ./flake-module.nix
  ];

  flake = {
    flakeModules = {
      home-manager = ./flake-module.nix;
    };

    homeManagerModules =
      let
        modules = {
          base = ./modules/base.nix;
          containers = ./modules/containers.nix;
          developer = ./modules/developer.nix;
          dotfiles = ./modules/dotfiles.nix;
          pigeonf = ./modules/pigeonf.nix;
          root = ./modules/root.nix;
          rust = ./modules/rust.nix;
          shell = ./modules/shell.nix;
          sysadmin = ./modules/sysadmin.nix;
        };
        programs = {
          _1password = ./modules/programs/_1password.nix;
          atuin = ./modules/programs/atuin.nix;
          bash = ./modules/programs/bash.nix;
          bat = ./modules/programs/bat.nix;
          btop = ./modules/programs/btop.nix;
          cargo = ./modules/programs/cargo.nix;
          eza = ./modules/programs/eza.nix;
          fd = ./modules/programs/fd.nix;
          ghq = ./modules/programs/ghq.nix;
          git = ./modules/programs/git.nix;
          helix = ./modules/programs/helix.nix;
          home-manager = ./modules/programs/home-manager.nix;
          jujutsu = ./modules/programs/jujutsu.nix;
          nix = ./modules/programs/nix.nix;
          nushell = ./modules/programs/nushell.nix;
          ripgrep = ./modules/programs/ripgrep.nix;
          starship = ./modules/programs/starship.nix;
          vscodium = ./modules/programs/vscodium.nix;
          yazi = ./modules/programs/yazi.nix;
          zellij = ./modules/programs/zellij.nix;
          zoxide = ./modules/programs/zoxide.nix;
          zsh = ./modules/programs/zsh.nix;
        };
      in
      modules
      // {
        inherit programs;

        default = _: {
          imports = builtins.attrValues modules;
        };
      };
  };

  perSystem =
    { pkgs, ... }:
    let
      home-manager-lib = inputs.home-manager.lib;
    in
    {
      homeConfigurations = {
        pigeonf = home-manager-lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [ ./configurations/pigeonf.nix ];
        };
        root = home-manager-lib.homeManagerConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs;
          };

          modules = [ ./configurations/root.nix ];
        };
      };
    };
}
