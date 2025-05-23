# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
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

      registry = {
        nixpkgs-stable = {
          exact = true;
          from = {
            type = "indirect";
            id = "nixpkgs-stable";
          };
          to = {
            type = "path";
            path = inputs.nixpkgs-stable;
          };
        };
      };

      settings = {
        auto-allocate-uids = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (lib.mkDefault true);
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
        sandbox = true;
        system-features = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [ "uid-range" ];
        trusted-users = [ "@wheel" ];
        use-cgroups = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (lib.mkDefault true);
        use-xdg-base-directories = lib.mkDefault true;
      };
    };
  };
}
