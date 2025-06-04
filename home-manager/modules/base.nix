# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ pkgs, ... }:
{
  _file = ./base.nix;

  imports = [
    ./programs/home-manager.nix
    ./programs/nix.nix
  ];

  config = {
    croissant = {
      programs = {
        nix.configure = true;
      };
    };

    home = {
      packages = [ pkgs.ncurses ];
    };
  };
}
