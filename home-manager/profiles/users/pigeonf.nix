# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ croissantModulesPath, ... }:
{
  _file = ./pigeonf.nix;

  imports = [
    (croissantModulesPath + "/profiles/base.nix")
    (croissantModulesPath + "/profiles/developer.nix")
    (croissantModulesPath + "/profiles/shell.nix")
  ];
}
