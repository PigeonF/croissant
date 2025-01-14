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
    inputs.disko.nixosModules.disko
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  config = {
    disko = {
      devices = {
        disk = {
          disk1 = {
            device = "/dev/sda";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                esp = {
                  label = "boot";
                  name = "ESP";
                  priority = 1;
                  size = "500M";
                  type = "EF00";
                  content = {
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [
                      "defaults"
                      "umask=0077"
                    ];
                    type = "filesystem";
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    };

    facter = {
      reportPath = ./facter.json;
    };

    virtualisation.incus.agent.enable = true;
  };
}
