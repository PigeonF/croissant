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
  inherit (lib) mkEnableOption mkOption types;

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
      rollback = {
        enable = mkEnableOption "enable rollback of the root dataset";
        datasets = mkOption {
          default = [
            "rpool/local/root"
            "rpool/safe/home"
          ];
          description = ''
            The datasets to roll back at boot.
          '';
          type = types.listOf (
            types.enum [
              "rpool/local/root"
              "rpool/safe/home"
              "rpool/safe/persist"
            ]
          );
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.zfs.enable) (
    lib.mkMerge [
      {
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
                rootFsOptions =
                  {
                    "com.sun:auto-snapshot" = "false";
                    compression = "zstd";
                    mountpoint = "none";
                  }
                  // lib.attrsets.optionalAttrs cfg.encryption.enable {
                    encryption = "aes-256-gcm";
                    keyformat = "passphrase";
                  };
                postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^rpool@blank$' || zfs snapshot rpool@blank";

                datasets = {
                  local = {
                    type = "zfs_fs";
                    options.mountpoint = "none";
                  };
                  "local/root" = {
                    type = "zfs_fs";
                    mountpoint = "/";
                    options = {
                      "com.sun:auto-snapshot" = "false";
                    };
                    postCreateHook = ''
                      zfs list -t snapshot -H -o name | grep -E '^rpool/local/root@blank$' || zfs snapshot rpool/local/root@blank
                    '';
                  };
                  "local/nix" = {
                    type = "zfs_fs";
                    mountpoint = "/nix";
                    options = {
                      acltype = "posixacl";
                      atime = "off";
                      xattr = "sa";
                      "com.sun:auto-snapshot" = "false";
                    };
                  };
                  "local/log" = {
                    type = "zfs_fs";
                    mountpoint = "/var/log";
                    options = {
                      atime = "off";
                      "com.sun:auto-snapshot" = "false";
                    };
                  };

                  safe = {
                    type = "zfs_fs";
                    options.mountpoint = "none";
                  };
                  "safe/home" = {
                    type = "zfs_fs";
                    mountpoint = "/home";
                    options = {
                      atime = "on";
                      relatime = "on";
                      "com.sun:auto-snapshot" = "true";
                    };
                    postCreateHook = ''
                      zfs list -t snapshot -H -o name | grep -E '^rpool/safe/home@blank$' || zfs snapshot rpool/safe/home@blank
                    '';
                  };
                  "safe/persist" = {
                    type = "zfs_fs";
                    mountpoint = "/persist";
                    options = {
                      atime = "on";
                      relatime = "on";
                      "com.sun:auto-snapshot" = "true";
                    };
                    postCreateHook = ''
                      zfs list -t snapshot -H -o name | grep -E '^rpool/safe/persist@blank$' || zfs snapshot rpool/safe/persist@blank
                    '';
                  };
                  "safe/shared" = {
                    type = "zfs_fs";
                    mountpoint = "/var/shared";
                    options = {
                      acltype = "posixacl";
                      atime = "on";
                      relatime = "on";
                      xattr = "sa";
                      "com.sun:auto-snapshot" = "true";
                    };
                    postCreateHook = ''
                      zfs list -t snapshot -H -o name | grep -E '^rpool/safe/shared@blank$' || zfs snapshot rpool/safe/shared@blank
                    '';
                  };

                  reserved = {
                    type = "zfs_fs";
                    options = {
                      canmount = "off";
                      mountpoint = "none";
                      reservation = "4GiB";
                    };
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
      (lib.mkIf cfg.zfs.rollback.enable {
        boot = {
          initrd = lib.mkIf cfg.zfs.rollback.enable {
            systemd = {
              enable = true;
              services = {
                rollback = {
                  description = "Rollback ZFS dataset to a pristine state";
                  wantedBy = [ "initrd.target" ];
                  after = [ "zfs-import.target" ];
                  before = [ "sysroot.mount" ];
                  unitConfig.DefaultDependencies = "no";
                  serviceConfig.Type = "oneshot";
                  script = ''
                    ${lib.strings.toShellVar "datasets" cfg.zfs.rollback.datasets}
                    for dataset in "''${datasets[@]}"; do
                      zfs rollback -r "$dataset@blank"
                    done
                  '';
                };
                persisted-files = {
                  description = "Hard-link files from /persist";
                  wantedBy = [ "initrd.target" ];
                  after = [ "sysroot.mount" ];
                  unitConfig.DefaultDependencies = "no";
                  serviceConfig.Type = "oneshot";
                  script = ''
                    mkdir -p /sysroot/etc/
                    ln -snfT /persist/etc/machine-id /sysroot/etc/machine-id
                  '';
                };
              };
            };
          };
        };

        environment = {
          etc."machine-id".source = "/persist/etc/machine-id";
        };

        fileSystems = {
          "/var/log".neededForBoot = true;
          "/persist".neededForBoot = true;
        };

        systemd = {
          tmpfiles.rules = (lib.mkIf config.networking.wireless.iwd.enable) [
            "d /persist/var/lib/iwd - - - -"
            "L+ /var/lib/iwd - - - - /persist/var/lib/iwd"
          ];
        };
      })
    ]
  );
}
