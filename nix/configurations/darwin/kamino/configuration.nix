# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  croissantNixOsPresetsPath,
  ...
}:
{
  _file = ./configuration.nix;

  imports = [
    "${croissantNixOsPresetsPath}/nix.nix"
    inputs.lix-modules.nixosModules.default
  ];

  config = {
    system = {
      stateVersion = 5;
    };
  };
}
