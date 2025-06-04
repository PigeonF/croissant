# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ lib, ... }:
{
  _file = ./nushell.nix;

  config = lib.mkMerge [
    {
      programs = {
        nushell = {
          enable = true;
        };
      };
    }
  ];
}
