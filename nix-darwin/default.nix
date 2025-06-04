# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./default.nix;

  imports = [
    ./flake-module.nix
  ];

  flake = {
    flakeModules = {
      nix-darwin = ./flake-module.nix;
    };

    darwinModules = {
      base = ./modules/base.nix;
      gitlab-tart-executor = ./modules/services/gitlab-tart-executor.nix;
      homebrew = ./modules/homebrew.nix;
      jupiter = ./configurations/jupiter;
      nix = ./modules/nix.nix;
    };
  };
}
