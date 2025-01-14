# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.croissant.disk;
  inherit (lib) mkEnableOption;

  # Because of https://github.com/nix-community/disko/issues/678 we have to duplicate this here.
  partition = lib.attrsets.optionalAttrs (cfg.partitionType == "gpt") {
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
  };
in
{
  _file = ./zfs.nix;

  options.croissant.disk = {
    zfs = {
      enable = mkEnableOption "use zfs for the disk configuration";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.zfs.enable) (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.zfs.enable -> !cfg.encryption.enable;
            message = ''
              Encryption is currently not supported for zfs.
            '';
          }
        ];

        disko = {
          devices = {
            disk = {
              disk1 = {
                name = "main";
                type = "disk";
                device = lib.mkDefault cfg.device;
                content = {
                  type = cfg.partitionType;
                  partitions = partition // {
                    rpool = {
                      size = "100%";
                      priority = 2;
                      content = {
                        type = "zfs";
                        pool = "rpool";
                      };
                    };
                  };
                };
              };
            };
            zpool = {
              rpool = {
                type = "zpool";
                rootFsOptions = {
                  "com.sun:auto-snapshot" = "false";
                  compression = "zstd";
                  mountpoint = "none";
                };
                datasets = {
                  nix = {
                    mountpoint = "/nix";
                    options = {
                      atime = "off";
                      "com.sun:auto-snapshot" = "false";
                    };
                    type = "zfs_fs";
                  };
                  root = {
                    mountpoint = "/";
                    options = {
                      "com.sun:auto-snapshot" = "false";
                    };
                    type = "zfs_fs";
                  };
                };
              };
            };
          };
          imageBuilder = {
            extraRootModules = [ "zfs" ];
          };
        };

        environment = {
          systemPackages = [ pkgs.zfs-prune-snapshots ];
        };

        networking = {
          hostId = lib.mkDefault (
            builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName)
          );
        };

        services = {
          zfs = {
            autoScrub = {
              enable = true;
              pools = [ "rpool" ];
            };
            trim.enable = true;
          };
        };
      }
    ]
  );
}
