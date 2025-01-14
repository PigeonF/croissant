# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  modulesPath,
  ...
}:
{
  _file = ./hardware-configuration.nix;

  imports = [
    "${modulesPath}/profiles/headless.nix"
    "${modulesPath}/profiles/minimal.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  config = {
    croissant = {
      disk = {
        enable = true;
        ext4.enable = true;
      };
    };

    facter = {
      reportPath = ./facter.json;
      detected = {
        dhcp.enable = false;
        graphics.enable = false;
      };
    };

    virtualisation.incus.agent.enable = true;
  };
}
