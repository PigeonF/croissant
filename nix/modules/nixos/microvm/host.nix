# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  ...
}:
let
  cfg = config.croissant.microvm.host;
  inherit (config.croissant) microvms;
  microvm-lib = import ./lib.nix { };
  inherit (lib) mkOption types;
  inherit (lib.strings) concatLines;
  inherit (lib.attrsets) mapAttrs' mapAttrsToList nameValuePair;
in
{
  _file = ./host.nix;

  options.croissant = {
    microvm.host = {
      externalInterface = mkOption {
        example = "enp5s0";
        description = ''
          The external interfaces that the VMs use to connect to the internet.
        '';
        type = types.str;
      };
    };
  };

  config = {
    environment = lib.mkIf (config.environment ? persistence) {
      persistence."/persist" = {
        directories = [ "/var/lib/microvms" ];
      };
    };

    networking = {
      firewall.enable = false;
      extraHosts = concatLines (
        mapAttrsToList (
          name: _:
          let
            microvm = microvms.vms.${name};
          in
          concatLines [
            "${microvm.ipv4} ${name}"
            "${microvm.ipv6} ${name}"
          ]
        ) config.microvm.vms
      );

      nat = {
        enable = true;
        internalIPs = [
          "${microvms.host.ipv4}/24"
        ];
        inherit (cfg) externalInterface;
      };
    };

    systemd.network = {
      networks = mapAttrs' (
        name: _value:
        nameValuePair "30-microvm-${name}" {
          matchConfig.Name = microvm-lib.vmToInterface name;
          address = [
            "${microvms.host.ipv4}/32"
            "${microvms.host.ipv6}/128"
          ];
          routes = [
            {
              Destination = "${microvms.vms.${name}.ipv4}/32";
            }
            {
              Destination = "${microvms.vms.${name}.ipv6}/128";
            }
          ];
          networkConfig = {
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        }
      ) config.microvm.vms;
    };
  };
}
