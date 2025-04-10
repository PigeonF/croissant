# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  pkgs,
  ...
}:
{
  _file = ./system.nix;

  config = {
    environment = {
      systemPackages = [
        pkgs.alacritty.terminfo
        pkgs.wezterm.terminfo
      ];
    };

    networking = {
      hostName = "phoebe";
      computerName = "Phoebe Server";
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      stateVersion = 5;
    };
  };
}
