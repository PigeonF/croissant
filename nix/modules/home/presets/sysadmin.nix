# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ pkgs, ... }:
{
  _file = ./sysadmin.nix;

  home.packages = builtins.attrValues { inherit (pkgs) dust nix-tree; };

  programs = {
    bat.enable = true;
    btop.enable = true;
    fd.enable = true;
    helix.enable = true;
    ripgrep.enable = true;
  };
}
