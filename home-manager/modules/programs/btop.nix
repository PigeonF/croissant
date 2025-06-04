# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ lib, ... }:
{
  _file = ./btop.nix;

  config = lib.mkMerge [
    {
      programs = {
        btop = {
          enable = true;
        };
      };
    }
  ];
}
