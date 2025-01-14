# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.croissant.disk;
  inherit (lib) mkEnableOption mkOption types;
in
{
  _file = ./default.nix;

  imports = [
    inputs.disko.nixosModules.disko
    ./ext4.nix
    ./zfs.nix
  ];

  options.croissant = {
    disk = {
      enable = mkEnableOption "a default disk configuration";

      device = mkOption {
        default = "/dev/sda";
        example = "/dev/nvme0n1";
        description = ''
          The path to the main disk device.
        '';
        type = types.str;
      };

      partitionType = mkOption {
        default = "gpt";
        description = ''
          The partition scheme to use.
        '';
        type = types.enum [ "gpt" ];
      };

      encryption = {
        enable = mkEnableOption "enable disk encryption";

        remoteUnlock = {
          enable = mkEnableOption "enable remote disk decryption";

          ssh = {
            enable = mkOption {
              default = cfg.encryption.remoteUnlock.enable;
              description = ''
                Whether to remotely decrypt the disk via ssh
              '';
              type = types.bool;
            };

            port = mkOption {
              type = types.port;
              default = 2222;
              description = ''
                Port on which SSH service should listen.
              '';
            };

            hostKeys = mkOption {
              type = types.listOf (types.either types.str types.path);
              default = [
                "/secrets/boot/ssh/ssh_host_ed25519_key"
              ];
              description = ''
                Specify SSH host keys.
              '';
            };

            authorizedKeys = mkOption {
              type = types.listOf types.str;
              default = config.users.users.root.openssh.authorizedKeys.keys;
              defaultText = lib.literalExpression "config.users.users.root.openssh.authorizedKeys.keys";
              description = ''
                Authorized keys that can unlock the disk.
              '';
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      let
        filesystems = builtins.attrValues { inherit (cfg) ext4 zfs; };
      in
      [
        {
          assertion = lib.lists.any (submodule: submodule.enable) filesystems;
          message = ''
            Croissant disk setup enabled, but none of the filesystem formats are enabled.
            Enable any of {option}`croissant.disk.ext4.enable {option}`croissant.disk.zfs.enable`.
          '';
        }
        {
          assertion = (lib.lists.count (submodule: submodule.enable) filesystems) == 1;
          message = ''
            Croissant disk setup enabled, but more than one filesystem formats is enabled.
          '';
        }
        {
          assertion = cfg.encryption.remoteUnlock.enable -> cfg.encryption.remoteUnlock.ssh.enable;
          message = "Remote unlock is currently only possible with ssh";
        }
      ];

    boot = {
      initrd = lib.mkIf cfg.encryption.remoteUnlock.enable {
        network = {
          ssh = {
            inherit (cfg.encryption.remoteUnlock.ssh)
              enable
              port
              hostKeys
              authorizedKeys
              ;
          };
        };
        secrets = {
          # Populated by `just generate-initrd-ssh-host-key <host>`
          "/secrets/boot/ssh/ssh_host_ed25519_key" =
            lib.mkForce "/persist/secrets/boot/etc/ssh/ssh_host_ed25519_key";
        };
        systemd = {
          enable = true;
          network = {
            enable = true;
            networks = {
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
            wait-online.anyInterface = true;
          };
          # systemctl does not recognize many TERM variables otherwise.
          storePaths = [ pkgs.ncurses ];
        };
      };
    };

    # https://github.com/nix-community/disko/issues/678
    # disko = {
    #   devices = {
    #     disk = {
    #       disk1 = {
    #         name = "main";
    #         type = "disk";
    #         device = lib.mkDefault cfg.device;
    #         content = {
    #           type = cfg.partitionType;
    #           partitions = lib.attrsets.optionalAttrs (cfg.partitionType == "gpt") {
    #             esp = {
    #               label = "boot";
    #               name = "ESP";
    #               priority = 1;
    #               size = "500M";
    #               type = "EF00";
    #               content = {
    #                 format = "vfat";
    #                 mountpoint = "/boot";
    #                 mountOptions = [
    #                   "defaults"
    #                   "umask=0077"
    #                 ];
    #                 type = "filesystem";
    #               };
    #             };
    #           };
    #         };
    #       };
    #     };
    #   };
    # };
  };
}
