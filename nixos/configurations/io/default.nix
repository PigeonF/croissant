# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  inputs,
  ...
}:
{
  imports = [
    # (modulesPath + "/installer/scan/not-detected.nix")
    # (modulesPath + "/profiles/qemu-guest.nix")
    inputs.nixos-lima.nixosModules.lima
    inputs.self.nixosModules.nix
    inputs.sops-nix.nixosModules.sops
  ];

  config = {
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

    networking = {
      # dhcpcd = {
      #   enable = false;
      # };
      hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
      # nftables = {
      #   enable = true;
      # };
      # useDHCP = false;
      # wireless = {
      #   enable = false;
      # };
    };

    services = {
      openssh = {
        enable = true;
      };
      lima = {
        enable = true;
      };
      resolved = {
        enable = true;
      };
    };

    systemd = {
      network = {
        enable = false;
        networks = {
          "05-container-bridge" = {
            matchConfig = {
              Type = "bridge";
              Name = "br-* docker* podman*";
            };
            linkConfig = {
              Unmanaged = "yes";
            };
          };
          "05-container-veth" = {
            matchConfig = {
              Type = "ether";
              Name = "veth*";
            };
            linkConfig = {
              Unmanaged = "yes";
            };
          };
          "10-uplink" = {
            matchConfig = {
              Type = "ether";
            };
            networkConfig = {
              DHCP = "yes";
            };
            linkConfig = {
              RequiredForOnline = "routable";
            };
          };
        };
        links = {
          "enp0s1" = {
            matchConfig = {
              Type = "ether";
              Name = "enp0s1";
            };
            linkConfig = {
              TCPSegmentationOffload = false;
              GenericSegmentationOffload = false;
            };
          };
        };
      };
    };

    system.disableInstallerTools = true;

    users = {
      users = {
        root = {
          openssh.authorizedKeys.keyFiles = [
            (../../../dotfiles/ssh/.ssh/keys.d + "/root@io.pub")
          ];
        };
      };
    };

    virtualisation.rosetta = {
      enable = true;
      mountTag = "vz-rosetta";
    };
  };
}
