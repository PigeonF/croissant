# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ pkgs, ... }:
{
  _file = ./virtualization.nix;

  config = {
    environment = {
      etc = {
        "resolv.conf" = {
          mode = "direct-symlink";
        };
        "containers/registries.conf.d/mirror-gcr.conf" = {
          source = pkgs.writeText "mirror-gcr.conf" ''
            [[registry]]
            location = "mirror.gcr.io"
            prefix = "docker.io"
          '';
        };
      };
      systemPackages = [ pkgs.passt ];
    };
    networking = {
      firewall = {
        trustedInterfaces = [
          "podman*"
        ];
      };
    };
    virtualisation = {
      containers = {
        enable = true;
      };
      docker = {
        enable = false;
      };
      oci-containers = {
        backend = "podman";
      };
      podman = {
        enable = true;
        autoPrune = {
          enable = true;
          flags = [ "--all" ];
        };
        defaultNetwork = {
          settings = {
            dns_enabled = true;
          };
        };
        dockerSocket = {
          enable = true;
        };
      };
    };
  };
}
