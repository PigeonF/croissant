# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./virtualization.nix;

  config = {
    environment = {
      etc = {
        "resolv.conf" = {
          mode = "direct-symlink";
        };
      };
    };
    networking = {
      firewall = {
        trustedInterfaces = [ "docker*" ];
      };
    };
    virtualisation = {
      docker = {
        enable = true;
      };
    };
  };
}
