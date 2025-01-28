# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  croissantPresetsPath,
  inputs,
  ...
}:
{
  _file = ./configuration.nix;

  imports = [
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/nixos/bash.nix"
    "${croissantPresetsPath}/nixos/network.nix"
    "${croissantPresetsPath}/nixos/users.nix"
    "${croissantPresetsPath}/nixos/xdg.nix"
    "${croissantPresetsPath}/openssh.nix"
    inputs.lix-modules.nixosModules.default
    inputs.microvm.nixosModules.microvm
    inputs.self.nixosModules.microvm-vm
  ];

  config = {
    croissant.microvm.defaultShares = false;
    microvm = {
      hypervisor = "firecracker";
      mem = 1024;
      vcpu = 1;

      volumes = [
        {
          image = "var-lib.img";
          mountPoint = "/var/lib";
          size =
            6 * 1024 # M
          ;
        }
      ];
    };

    networking = {
      hostName = "mustafar";
    };

    services = {
      openssh.enable = true;
    };

    system = {
      stateVersion = "25.05";
    };

    users = {
      users.root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSGbm3QEVQFhYqJM29rQ6WibpQr613KgxoYTr/QvztV"
        ];
      };
    };
  };
}
