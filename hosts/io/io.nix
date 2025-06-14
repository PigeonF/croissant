{
  config,
  pkgs,
  inputs,
  lib,
  # croissantHomeManagerModulesPath,
  ...
}:
{
  _file = ./io.nix;

  imports = [
    # inputs.home-manager.nixosModules.home-manager
    inputs.lix-modules.nixosModules.default
    inputs.nixos-generators.nixosModules.all-formats
    inputs.nixos-lima.nixosModules.lima
    inputs.sops-nix.nixosModules.sops
  ];

  options = {
    io = {
      bootstrap = lib.mkEnableOption "io bootstrap";
    };
  };

  config = lib.mkMerge [
    {
      formatConfigs = {
        qcow-efi = _: {
          io.bootstrap = true;

          # home-manager = {
          #   extraSpecialArgs = {
          #     croissantModulesPath = croissantHomeManagerModulesPath;
          #     inherit inputs;
          #   };

          #   users = {
          #     root = ./root.nix;
          #   };
          # };
        };
      };
    }
    (lib.mkIf (!config.io.bootstrap) {
      sops = {
        defaultSopsFile = ./secrets/io.yaml;
      };

      services = {
        gitlab-runner = {
          enable = true;

          clear-docker-cache = {
            enable = true;
          };

          gracefulTermination = true;
          gracefulTimeout = "30s";

          settings = {
            concurrent = 16;
            check_interval = 15;
          };

          services = {
            container = {
              limit = 12;
              authenticationTokenConfigFile = config.sops.templates."container-authentication-token.env".path;
              description = "Self-managed runner for docker executor (io)";
              dockerImage = "docker.io/library/busybox";
              executor = "docker";
              registrationFlags = [
                "--cache-dir /cache"
                "--docker-host unix:///run/podman/podman.sock"
                "--docker-network-mode podman"
                "--docker-volumes /builds"
                "--docker-volumes /cache"
                "--docker-volumes /var/lib/containers"
              ];
            };
          };
        };
      };

      sops = {
        templates = {
          "container-authentication-token.env" = {
            content = ''
              CI_SERVER_URL=https://gitlab.com
              CI_SERVER_TOKEN=${config.sops.placeholder."services/gitlab-runner/container/authentication-token"}
            '';
          };
        };
        secrets = {
          "services/gitlab-runner/container/authentication-token" = {
            restartUnits = [ "gitlab-runner.service" ];
          };
        };
      };
    })
    {
      boot = {
        binfmt = {
          emulatedSystems = [ "x86_64-linux" ];
          # TODO(PigeonF): Set to `true` once https://github.com/NixOS/nixpkgs/issues/392673 is fixed.
          preferStaticEmulators = false;
        };

        kernelParams = [ "console=tty0" ];

        loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot.enable = true;
        };
      };

      documentation.enable = false;

      fileSystems = {
        "/boot" = {
          device = "/dev/disk/by-label/ESP";
          fsType = "vfat";
          options = [
            "discard"
            "noatime"
            "umask=0077"
          ];
        };
        "/" = {
          device = "/dev/disk/by-label/nixos";
          label = "nixos";
          autoResize = true;
          fsType = "ext4";
          options = [
            "discard"
            "noatime"
          ];
        };
      };

      networking = {
        firewall = {
          trustedInterfaces = [
            "podman*"
          ];
        };
        dhcpcd = {
          enable = false;
        };
        hostName = "io";
        hostId = builtins.substring 0 8 (builtins.hashString "sha256" config.networking.hostName);
        nftables = {
          enable = true;
        };
        useDHCP = false;
        wireless = {
          enable = false;
        };
      };

      environment = {
        etc = {
          "resolv.conf" = {
            mode = "direct-symlink";
          };

          "containers/registries.conf.d/mirror-gcr.conf" = {
            source = pkgs.writeText "mirror-gcr.conf" ''
              [[registry]]
              location = "mirror.gcr.io"
              prefix = "docker.io"
            '';
          };
        };
        systemPackages = [ pkgs.passt ];
      };

      systemd = {
        services = {
          gitlab-runner-clear-docker-cache = {
            path = [ pkgs.bash ];
          };
        };
        network = {
          enable = true;
          networks = {
            "05-container-bridge" = {
              matchConfig = {
                Type = "bridge";
                Name = "docker* podman* br-*";
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

      nix = {
        channel.enable = false;
        registry.nixpkgs.flake = inputs.nixpkgs;

        settings = {
          auto-optimise-store = true;
          experimental-features = [
            "flakes"
            "nix-command"
          ];

          trusted-users = [ "lima" ];
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
      };

      virtualisation = {
        containers = {
          enable = true;
        };
        docker = {
          enable = false;
        };
        oci-containers = {
          backend = "podman";
        };
        podman = {
          enable = true;
          autoPrune = {
            enable = true;
            flags = [ "--all" ];
          };
          defaultNetwork = {
            settings = {
              dns_enabled = true;
            };
          };
          dockerSocket = {
            enable = true;
          };
        };
        rosetta = {
          enable = true;

          # Lima's virtiofs label for rosetta:
          # https://github.com/lima-vm/lima/blob/0e931107cadbcb6dbc7bbb25626f66cdbca1f040/pkg/vz/rosetta_directory_share_arm64.go#L15
          mountTag = "vz-rosetta";
        };
      };
    }
  ];
}
