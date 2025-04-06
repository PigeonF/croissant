# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ pkgs, ... }:
{
  _file = ./graphics.nix;

  config = {
    environment = {
      systemPackages = [
        pkgs.alacritty
        pkgs.ghostty
      ];
    };
    programs = {
      firefox = {
        enable = true;
      };
      niri = {
        enable = true;
      };
    };
    services = {
      displayManager = {
        ly = {
          enable = true;
          settings = {
            # XXX(PigeonF): Wait for new ly version
            # brightness_down_cmd = "${lib.getExe pkgs.brightnessctl} -q s 10%-";
            # brightness_down_key = "F5";
            # brightness_up_cmd = "${lib.getExe pkgs.brightnessctl} -q s +10%";
            # brightness_up_key = "F6";
            clock = "%c";
          };
        };
      };
    };
  };
}
