# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  ...
}:
{
  _file = ./starship.nix;

  config = lib.mkMerge [
    {
      programs = {
        starship = {
          enable = true;
        };
      };
    }
  ];
}
