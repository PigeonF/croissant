# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  _file = ./microvms.nix;

  options.croissant = {
    microvms = {
      host = mkOption {
        description = ''
          The IP address of the microvm host.
        '';
        type = types.unspecified;
        default = {
          ipv4 = "10.127.0.0";
          ipv6 = "fd12:3456:789a::";
        };
        internal = true;
        readOnly = true;
      };
      vms = mkOption {
        description = ''
          The available micro vm hostnames mapped to their ip addresses.
        '';
        type = types.unspecified;
        default = {
          raxus = {
            ipv4 = "10.127.0.127";
            ipv6 = "fec0:0a7f::7f";
            mac = "02:00:00:00:00:7f";
          };
        };
        internal = true;
        readOnly = true;
      };
    };
  };
}
