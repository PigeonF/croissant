# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./pigeonf.nix;

  imports = [
    ./base.nix
    ./developer.nix
    ./shell.nix

    ./programs/ghq.nix
    ./programs/git.nix
    ./programs/helix.nix
    ./programs/jujutsu.nix
    ./programs/zellij.nix
  ];

  config = {
    croissant = {
      programs = {
        git.configure = true;
        jujutsu.configure = true;
      };
    };
  };
}
