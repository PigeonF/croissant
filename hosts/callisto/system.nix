# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  ...
}:
{
  _file = ./system.nix;

  config = {
    networking = {
      hostName = "callisto";
      computerName = "MacBook Callisto";
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      stateVersion = 5;

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToControl = true;
      };
    };
  };
}
