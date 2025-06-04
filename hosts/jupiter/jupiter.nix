# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  ...
}:
{
  _file = ./jupiter.nix;

  imports = [
    inputs.lix-modules.nixosModules.default
    inputs.self.darwinModules.jupiter
  ];

  config = {
    networking = {
      hostName = "jupiter";
      computerName = "Jupiter Mac Mini";
    };

    sops = {
      defaultSopsFile = ./secrets/jupiter.yaml;
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      stateVersion = 6;
    };
  };
}
