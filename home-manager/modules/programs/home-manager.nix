# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  ...
}:
{
  _file = ./home-manager.nix;

  config = lib.mkMerge [
    {
      programs = {
        home-manager = {
          enable = true;
        };
      };
    }
  ];
}
