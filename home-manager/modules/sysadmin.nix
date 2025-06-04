# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ pkgs, ... }:
{
  _file = ./sysadmin.nix;

  imports = [
    ./programs/btop.nix
  ];

  config = {
    home = {
      packages = [
        pkgs.dust
        pkgs.nix-tree
      ];
    };
  };
}
