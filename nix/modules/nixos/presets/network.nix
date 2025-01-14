# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ config, lib, ... }:
{
  _file = ./network.nix;

  config = {
    networking = {
      dhcpcd.enable = lib.mkDefault false;

      useDHCP = lib.mkDefault false;

      wireless = {
        enable = lib.mkDefault false;

        iwd = {
          enable = lib.mkDefault true;
          settings = {
            General.UseDefaultInterface = lib.mkDefault true;
            DriverQuirks = {
              DefaultInterface = lib.mkDefault "*";
            };
          };
        };
      };
    };

    services = {
      resolved.enable = lib.mkOverride 999 (!config.boot.isContainer);
    };

    systemd = {
      network.enable = lib.mkDefault true;
    };
  };
}
