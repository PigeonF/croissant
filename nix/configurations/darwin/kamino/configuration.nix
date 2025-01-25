# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  lib,
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
    environment = {
      variables = {
        XDG_CACHE_HOME = lib.mkDefault "$HOME/.cache";
        XDG_CONFIG_HOME = lib.mkDefault "$HOME/.config";
        XDG_DATA_HOME = lib.mkDefault "$HOME/.local/share";
        XDG_STATE_HOME = lib.mkDefault "$HOME/.local/state";
      };

      profiles = lib.mkForce [
        "\${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"
        "/run/current-system/sw"
        "/nix/var/nix/profiles/default"
      ];
    };

    system = {
      stateVersion = 5;
    };
  };
}
