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
      pathsToLink = [ "/share/terminfo" ];
      systemPackages = [
        pkgs.alacritty.terminfo
        pkgs.wezterm.terminfo
      ];
      variables = {
        LANG = "en_US.UTF-8";
        LC_COLLATE = "C";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        # en_DK is not installed on macOS by default, so just fall back to en_GB
        LC_TIME = "en_GB.UTF-8";
      };
    };

    networking = {
      hostName = "callisto";
      computerName = "MacBook Callisto";
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

      defaults = {
        NSGlobalDomain = {
          InitialKeyRepeat = 20;
          KeyRepeat = 2;
        };
      };

      stateVersion = 5;

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };
  };
}
