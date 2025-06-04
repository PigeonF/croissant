# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./default.nix;

  flake = {
    nixosModules = {
      io = ./configurations/io;
      nix = ./modules/nix.nix;
    };
  };
}
