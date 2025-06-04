# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  pkgs,
  ...
}:
{
  _file = ./containers.nix;

  config = {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          crane
          diffoci
          diffoscopeMinimal
          dive
          ;
      };
    };
  };
}
