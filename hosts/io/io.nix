# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  lib,
  ...
}:
{
  _file = ./io.nix;

  imports = [
    # inputs.lix-modules.nixosModules.default
    # inputs.self.nixosModules.io
    inputs.nixos-lima.nixosModules.lima
    inputs.nixos-generators.nixosModules.all-formats
  ];

  config = {
    # formatConfigs.qcow-efi =
    #   { config, ... }:
    #   {
    #     users.users.root.openssh.authorizedKeys.keyFiles = [
    #       (../../dotfiles/ssh/.ssh/keys.d + "/lima@lima.pub")
    #     ];
    #   };

    # networking = {
    #   hostName = "io";
    # };

    # sops = {
    #   defaultSopsFile = ./secrets/io.yaml;
    # };
    boot = {
      kernelParams = [ "console=tty0" ];

      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot.enable = true;
      };
    };

    documentation.enable = false;

    fileSystems = {
      "/".options = [
        "discard"
        "noatime"
      ];
      "/boot".options = [
        "discard"
        "noatime"
        "umask=0077"
      ];
    };

    networking.hostName = "io";

    nix = {
      channel.enable = false;
      registry.nixpkgs.flake = inputs.nixpkgs;

      settings = {
        auto-optimise-store = true;
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        # min-free = "5G";
        # max-free = "7G";
      };
    };

    security = {
      sudo = {
        enable = true;
        wheelNeedsPassword = false;
      };
    };

    services = {
      openssh = {
        enable = true;
      };
      lima = {
        enable = true;
      };
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      disableInstallerTools = true;
      stateVersion = "25.05";
    };

    systemd.services.lima-guestagent = {
      serviceConfig = {
        ExecStart = lib.mkForce "/mnt/lima-cidata/lima-guestagent daemon --vsock-port 2222";
        OOMPolicy = "continue";
        OOMScoreAdjust = "-500";
        StandardOutput = "journal+console";
        StandardError = "journal+console";
      };
    };

    users = {
      mutableUsers = true;

      users.root = {
        openssh.authorizedKeys.keyFiles = [
          (../../dotfiles/ssh/.ssh/keys.d + "/root@oberon.pub")
        ];
      };
    };

    virtualisation.rosetta = {
      enable = true;

      # Lima's virtiofs label for rosetta:
      # https://github.com/lima-vm/lima/blob/0e931107cadbcb6dbc7bbb25626f66cdbca1f040/pkg/vz/rosetta_directory_share_arm64.go#L15
      mountTag = "vz-rosetta";
    };
  };
}
