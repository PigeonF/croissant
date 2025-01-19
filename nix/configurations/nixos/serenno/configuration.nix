# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  croissantPresetsPath,
  inputs,
  lib,
  modulesPath,
  ...
}:
{
  _file = ./configuration.nix;

  imports = [
    ./system.nix
    ./webserver.nix
    "${croissantPresetsPath}/bash.nix"
    "${croissantPresetsPath}/network.nix"
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/openssh.nix"
    "${croissantPresetsPath}/users.nix"
    "${modulesPath}/profiles/perlless.nix"
    inputs.impermanence.nixosModules.impermanence
    inputs.microvm.nixosModules.host
    inputs.self.nixosModules.microvm-host
    inputs.sops-nix.nixosModules.sops
  ];

  config = {
    environment = {
      persistence."/persist" = {
        hideMounts = true;

        directories = [
          "/var/lib/nixos"
        ];
      };
    };

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

    croissant = {
      microvm.host.externalInterface = "enp5s0";
      serenno.virtualhosts = {
        "fierlings.family" = "raxus";
      };
    };

    microvm = {
      autostart = [
        "raxus"
      ];
      vms = {
        raxus = {
          flake = inputs.self;
        };
      };
    };

    system = {
      stateVersion = "25.05";
      forbiddenDependenciesRegexes = lib.mkForce [ ];
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
