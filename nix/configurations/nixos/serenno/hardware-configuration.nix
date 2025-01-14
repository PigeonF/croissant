# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  lib,
  modulesPath,
  system,
  ...
}:
{
  _file = ./hardware-configuration.nix;

  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  config = {
    nixpkgs.hostPlatform = lib.mkDefault system;
  };
}
