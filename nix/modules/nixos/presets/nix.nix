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
      channel.enable = lib.mkDefault false;

      package = pkgs.nixVersions.stable;

      settings = {
        extra-experimental-features = [
          "auto-allocate-uids"
          "cgroups"
          "flakes"
          "nix-command"
          "no-url-literals"
        ];

        auto-allocate-uids = lib.mkDefault true;
        system-features = [ "uid-range" ];
        use-cgroups = lib.mkDefault true;
        use-xdg-base-directories = lib.mkDefault true;
      };
    };
  };
}
