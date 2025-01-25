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
          # Usually only laptops need `iwd`, which represents the smallest
          # amount of configurations for this repo.
          enable = lib.mkDefault false;
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
      network = {
        enable = lib.mkDefault true;
        # Set by the iwd module by default, but we want to use the systemd naming scheme.
        links."80-iwd".linkConfig.NamePolicy = lib.mkOverride 999 "keep kernel database onboard slot path";
      };
    };
  };
}
