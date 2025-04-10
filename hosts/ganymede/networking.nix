# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  ...
}:
{
  _file = ./networking.nix;

  config = {
    boot = {
      initrd = {
        network = {
          ssh = {
            enable = true;
            port = 2222;
            hostKeys = [ "/boot/etc/ssh/ssh_host_ed25519_key" ];
            authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
          };
        };

        secrets = {
          "/boot/etc/ssh/ssh_host_ed25519_key" = lib.mkForce "/persist/boot/etc/ssh/ssh_host_ed25519_key";
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
              };
            };
          };

          services = {
            remote-unlock = {
              description = "Prepare .profile for remote unlock";
              wantedBy = [ "initrd.target" ];
              after = [ "network-online.target" ];
              unitConfig.DefaultDependencies = "no";
              serviceConfig.Type = "oneshot";
              script = ''
                echo "systemctl default" > /var/empty/.profile
              '';
            };
          };

          # For TERM variables when using SSH
          storePaths = [ pkgs.ncurses ];
        };
      };

      kernelModules = [
        "iwlwifi"
      ];
    };

    environment = {
      persistence = {
        "/persist" = {
          directories = [
            "/var/lib/iwd"
          ];
        };
      };
      systemPackages = [
        pkgs.impala
      ];
    };

    facter = {
      detected = {
        # Only use DHCP for specific interfaces
        dhcp = {
          enable = false;
        };
      };
    };

    networking = {
      dhcpcd = {
        enable = false;
      };
      hostName = "ganymede";
      hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
      nftables = {
        enable = true;
      };
      useDHCP = false;
      wireless = {
        enable = false;
        iwd = {
          enable = true;
          settings = {
            Scan = {
              DisablePeriodicScan = true;
            };
            DriverQuirks = {
              DefaultInterface = "*";
            };
          };
        };
      };
    };

    services = {
      openssh = {
        enable = true;
      };
      resolved.enable = true;
    };

    systemd = {
      network = {
        enable = true;
        # Set by the iwd module by default, but we want to use the systemd naming scheme.
        links = {
          "80-iwd".linkConfig.NamePolicy = lib.mkOverride 999 "keep kernel database onboard slot path";
        };
        networks = {
          "05-enp0s31f6" = {
            matchConfig = {
              Name = "enp0s31f6";
              Type = "ether";
            };
            address = [
              "192.168.178.123/24"
              "fd21:5e04::/64"
            ];
            gateway = [ "192.168.178.1" ];
            dns = [ "192.168.178.53" ];
            linkConfig = {
              RequiredForOnline = "routable";
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
          "10-wireless" = {
            matchConfig = {
              Type = "wlan";
            };
            networkConfig = {
              DHCP = "yes";
            };
            linkConfig = {
              # Unmanaged = "yes";
              RequiredForOnline = "no";
            };
          };
        };
      };

      services = {
        iwd = {
          bindsTo = [ "systemd-networkd.service" ];
          after = [ "systemd-networkd.service" ];
        };
      };
    };
  };
}
