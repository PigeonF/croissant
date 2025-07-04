{
  config,
  ...
}:
{
  _file = ./networking.nix;

  config = {
    networking = {
      dhcpcd = {
        enable = false;
      };
      hostName = "oberon";
      hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
      nftables = {
        enable = true;
      };
      useDHCP = false;
      wireless = {
        enable = false;
      };
    };

    services = {
      openssh = {
        enable = true;
      };
      resolved = {
        enable = true;
      };
    };

    systemd = {
      network = {
        enable = true;
        networks = {
          "05-container-bridge" = {
            matchConfig = {
              Type = "bridge";
              Name = "docker* br-*";
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
  };
}
