# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./virtualization.nix;

  config = {
    environment = {
      persistence = {
        "/cache" = {
          directories = [
            "/var/lib/docker"
          ];
        };
      };
    };
    virtualisation = {
      docker = {
        enable = true;
      };
    };
  };
}
