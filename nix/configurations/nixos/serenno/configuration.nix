# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  croissantPresetsPath,
  inputs,
  modulesPath,
  ...
}:
{
  _file = ./configuration.nix;

  imports = [
    ./system.nix
    "${croissantPresetsPath}/bash.nix"
    "${croissantPresetsPath}/network.nix"
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/openssh.nix"
    "${croissantPresetsPath}/users.nix"
    "${modulesPath}/profiles/perlless.nix"
    inputs.sops-nix.nixosModules.sops
  ];
  config = {
    networking = {
      hostName = "serenno";
    };

    services = {
      openssh.enable = true;
    };

    sops = {
      defaultSopsFile = ./secrets.yaml;
      secrets = {
        "root/password" = {
          neededForUsers = true;
        };
      };
    };

    system = {
      stateVersion = "25.05";
    };

    users = {
      users.root = {
        hashedPassword = null;
        hashedPasswordFile = config.sops.secrets."root/password".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSGbm3QEVQFhYqJM29rQ6WibpQr613KgxoYTr/QvztV"
        ];
      };
    };
  };
}
