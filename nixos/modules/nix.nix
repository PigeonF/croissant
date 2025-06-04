# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
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
      settings = {
        auto-allocate-uids = true;
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
  };
}
