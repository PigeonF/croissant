# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  pkgs,
  ...
}:
{
  _file = ./nix.nix;

  config = {
    nix = {
      package = pkgs.nixVersions.stable;

      settings = {
        use-xdg-base-directories = lib.mkDefault true;
      };
    };
  };
}
