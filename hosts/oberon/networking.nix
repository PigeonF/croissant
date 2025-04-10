# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  ...
}:
{
  _file = ./networking.nix;

  config = {
    networking = {
      dhcpcd = {
        enable = false;
      };
      hostName = "oberon";
      hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
      nftables = {
        enable = true;
      };
      useDHCP = false;
      wireless = {
        enable = false;
      };
    };

    services = {
      openssh = {
        enable = true;
      };
      resolved.enable = true;
    };

    systemd = {
      network = {
        enable = true;
        networks = {
          "10-uplink" = {
            matchConfig = {
              Type = "ether";
            };
            networkConfig = {
              DHCP = "yes";
            };
            linkConfig = {
              RequiredForOnline = "routable";
            };
          };
        };
      };
    };
  };
}
