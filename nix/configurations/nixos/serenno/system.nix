# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  ...
}:
{
  _file = ./system.nix;

  config = {
    services = {
      resolved.domains = [ "incus" ];
    };

    systemd.network.networks = {
      "10-uplink" = {
        matchConfig = {
          Name = lib.mkDefault "en* eth0";
          Type = lib.mkDefault "ether";
          Kind = lib.mkDefault "veth";
        };
        networkConfig = {
          DHCP = lib.mkDefault "yes";
        };
        linkConfig = {
          RequiredForOnline = lib.mkDefault "routable";
        };
      };
    };
  };
}
