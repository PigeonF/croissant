# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  ...
}:
let
  inherit (config.croissant) microvms;
  microvm-lib = import ./lib.nix { };
in
{
  _file = ./vm.nix;

  config =
    let
      inherit (config.networking) hostName;
    in
    {
      networking.firewall.enable = false;
      microvm = {
        interfaces = [
          {
            type = "tap";
            id = microvm-lib.vmToInterface hostName;
            inherit (microvms.vms.${hostName}) mac;
          }
        ];
        shares = [
          {
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
            tag = "ro-store";
            proto = "virtiofs";
          }
          {
            mountPoint = "/persist";
            proto = "virtiofs";
            source = "/persist/microvms/${hostName}/";
            tag = "persist";
          }
        ];
      };

      systemd.network = {
        enable = lib.mkDefault true;
        networks = {
          "10-uplink" = {
            matchConfig.MACAddress = microvms.vms.${hostName}.mac;
            address = [
              "${microvms.vms.${hostName}.ipv4}/32"
              "${microvms.vms.${hostName}.ipv6}/128"
            ];
            routes = [
              {
                Destination = "${microvms.host.ipv4}/32";
                GatewayOnLink = true;
              }
              {
                Destination = "0.0.0.0/0";
                Gateway = microvms.host.ipv4;
                GatewayOnLink = true;
              }
              {
                Destination = "::/0";
                Gateway = microvms.host.ipv6;
                GatewayOnLink = true;
              }
            ];
            networkConfig.DNS = [
              microvms.host.ipv4
              microvms.host.ipv6
            ];
          };
        };
      };
    };
}
