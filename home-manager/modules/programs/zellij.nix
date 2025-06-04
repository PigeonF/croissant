# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  ...
}:
{
  _file = ./zellij.nix;

  config = lib.mkMerge [
    {
      programs = {
        zellij = {
          enable = true;
          enableBashIntegration = false;
          enableFishIntegration = false;
          enableZshIntegration = false;
        };
      };
    }
  ];
}
