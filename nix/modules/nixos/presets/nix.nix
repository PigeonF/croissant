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
        extra-experimental-features =
          [
            "flakes"
            "nix-command"
            "no-url-literals"
          ]
          ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            "auto-allocate-uids"
            "cgroups"
          ];

        auto-allocate-uids = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (lib.mkDefault true);
        system-features = [ "uid-range" ];
        use-cgroups = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (lib.mkDefault true);
        use-xdg-base-directories = lib.mkDefault true;
      };
    };
  };
}
