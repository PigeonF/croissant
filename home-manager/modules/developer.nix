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
      packages = [
        pkgs.age
        pkgs.curl
        pkgs.jq
        pkgs.just
        pkgs.patchedPackages.reuse
        pkgs.sd
        pkgs.sops
        pkgs.ssh-to-age
        pkgs.yq-go
      ];
    };
  };
}
