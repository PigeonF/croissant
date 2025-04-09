# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./disks.nix;

  config = {
    boot = {
      initrd = {
        systemd = {
          enable = true;
          services = {
            btrfs-rollback = {
              description = "Rollback BTRFS root subvolume to a pristine state";
              wantedBy = [ "initrd.target" ];
              before = [ "sysroot.mount" ];
              after = [
                "systemd-cryptsetup@cryptroot.service"
              ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = ''
                mkdir -p /mnt
                mount -o subvolid=5 -t btrfs /dev/mapper/cryptroot /mnt
                btrfs subvolume list -o /mnt/root
                btrfs subvolume list -o /mnt/root | cut -f9 -d' ' | while read subvolume; do
                  echo "deleting /$subvolume subvolume..."
                  btrfs subvolume delete "/mnt/$subvolume"
                done && echo "deleting /root subvolume..." && btrfs subvolume delete /mnt/root
                echo "restoring blank /root subvolume..."
                btrfs subvolume snapshot /mnt/root-blank /mnt/root
                umount /mnt
              '';
            };
          };
        };
      };
    };

    disko = {
      devices = {
        disk = {
          nvme0n1 = {
            type = "disk";
            device = "/dev/disk/by-id/nvme-eui.0025388781b5fae7";
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
                luks = {
                  size = "100%";
                  label = "luks";
                  content = {
                    type = "luks";
                    name = "cryptroot";
                    # Installed by nixos-anywhere
                    passwordFile = "/tmp/disk.key";
                    extraOpenArgs = [
                      "--allow-discards"
                      "--perf-no_read_workqueue"
                      "--perf-no_write_workqueue"
                    ];
                    settings = {
                      crypttabExtraOpts = [
                        "fido2-device=auto"
                        "token-timeout=10"
                      ];
                    };
                    content = {
                      type = "btrfs";
                      extraArgs = [
                        "-L"
                        "nixos"
                        "-f"
                      ];
                      # Used by the btrfs-rollback service
                      postCreateHook = ''
                        MNTPOINT=$(mktemp -d)
                        mount "/dev/mapper/cryptroot" "$MNTPOINT" -o subvolid=5
                        trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
                        btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
                      '';
                      subvolumes = {
                        "/root" = {
                          mountpoint = "/";
                          mountOptions = [
                            "subvol=root"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/nix" = {
                          mountpoint = "/nix";
                          mountOptions = [
                            "subvol=nix"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/log" = {
                          mountpoint = "/var/log";
                          mountOptions = [
                            "subvol=log"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/persist" = {
                          mountpoint = "/persist";
                          mountOptions = [
                            "subvol=persist"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/cache" = {
                          mountpoint = "/cache";
                          mountOptions = [
                            "subvol=cache"
                            "compress=zstd"
                            "noatime"
                          ];
                        };
                        "/swap" = {
                          mountpoint = "/swap";
                          swap.swapfile.size = "32G";
                        };
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };

    environment = {
      # XXX(PigeonF): The machine id is re-created on each boot (probably due to initrd shenanigangs).
      etc = {
        "machine-id" = {
          source = "/persist/etc/machine-id";
        };
      };
      persistence = {
        "/persist" = {
          hideMounts = true;
          directories = [
            "/var/lib/nftables"
            "/var/lib/nixos"
            "/var/lib/private"
            "/var/lib/systemd"
          ];
        };

        "/cache" = {
          hideMounts = true;
          directories = [
            "/var/lib/machines"
            "/var/lib/portables"
          ];
        };
      };
    };

    fileSystems = {
      # Cache and persist are used for the impermanence setup
      "/cache" = {
        neededForBoot = true;
      };
      "/persist" = {
        neededForBoot = true;
      };
      # Used by systemd
      "/var/log" = {
        neededForBoot = true;
      };
    };
  };
}
