# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  croissantPresetsPath,
  ...
}:
{
  _file = ./configuration.nix;

  imports = [
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/darwin/xdg.nix"
    inputs.lix-modules.nixosModules.default
  ];

  config = {
    homebrew = {
      enable = true;
      casks = [ "docker" ];
    };

    networking = {
      computerName = "kamino";
    };

    system = {
      stateVersion = 5;
    };
  };
}
