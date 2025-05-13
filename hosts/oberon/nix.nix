# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  pkgs,
  ...
}:
{
  _file = ./nix.nix;

  config = {
    nix = {
      channel = {
        enable = false;
      };
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
        auto-allocate-uids = true;
        # download-buffer-size = 512 * 1024 * 1024;
        extra-experimental-features = [
          "flakes"
          "nix-command"
          "no-url-literals"
          "auto-allocate-uids"
          "cgroups"
        ];
        sandbox = true;
        system-features = [ "uid-range" ];
        trusted-users = [ "@wheel" ];
        use-cgroups = true;
        use-xdg-base-directories = true;
      };
    };

    nixpkgs = {
      config = {
        allowBroken = true;
      };
    };
  };
}
