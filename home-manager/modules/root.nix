# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./root.nix;

  imports = [
    ./base.nix
    ./shell.nix

    ./programs/git.nix
    ./programs/helix.nix
  ];
}
