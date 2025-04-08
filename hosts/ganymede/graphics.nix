# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ pkgs, ... }:
{
  _file = ./graphics.nix;

  config = {
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
      systemPackages = [
        pkgs.alacritty
        pkgs.fuzzel
        pkgs.ghostty
        pkgs.wl-clipboard
        pkgs.swaylock
        pkgs.xsel
        pkgs.xwayland-satellite
      ];
    };
    fonts = {
      # TODO(PigeonF): Move to alacritty home manager module
      packages = [
        pkgs.nerd-fonts.recursive-mono
        pkgs.nerd-fonts.victor-mono
      ];
    };
    programs = {
      _1password = {
        enable = true;
      };
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "pigeonf" ];
      };
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
