# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./default.nix;

  imports = [
    ./flake-module.nix
    # ./io
    ./jupiter
  ];

  flake = {
    flakeModules = {
      deploy-rs = ./flake-module.nix;
    };
  };
}
