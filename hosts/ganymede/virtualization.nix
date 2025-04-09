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
            "/var/lib/containerd"
            "/var/lib/docker"
          ];
        };
      };
    };
    virtualisation = {
      docker = {
        rootless = {
          enable = true;
          setSocketVariable = true;
          daemon = {
            settings = {
              dns = [ "1.1.1.1" ];
              default-address-pools = [
                {
                  "base" = "172.72.0.0/16";
                  "size" = 24;
                }
              ];
            };
          };
        };
      };
    };
  };
}
