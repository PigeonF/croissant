# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  pkgs,
  ...
}:
{
  _file = ./system.nix;

  config = {
    boot = {
      initrd = {
        systemd = {
          enable = true;
        };
      };

      kernelModules = [ "kvm-intel" ];

      loader = {
        efi = {
          canTouchEfiVariables = true;
        };
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
      };

      tmp = {
        useTmpfs = true;
      };
    };

    environment = {
      enableAllTerminfo = true;
      localBinInPath = true;
      systemPackages = [
        pkgs.glibcLocales
        # https://kokada.capivaras.dev/blog/quick-bits-realise-nix-symlinks/
        (pkgs.writeShellApplication {
          name = "realise-symlink";
          runtimeInputs = with pkgs; [ coreutils ];
          text = ''
            for file in "$@"; do
              if [[ -L "$file" ]]; then
                if [[ -d "$file" ]]; then
                  tmpdir="''${file}.tmp"
                  mkdir -p "$tmpdir"
                  cp --verbose --recursive "$file"/* "$tmpdir"
                  unlink "$file"
                  mv "$tmpdir" "$file"
                  chmod --changes --recursive +w "$file"
                else
                  cp --verbose --remove-destination "$(readlink "$file")" "$file"
                  chmod --changes +w "$file"
                fi
              else
                >&2 echo "Not a symlink: $file"
                exit 1
              fi
            done
          '';
        })
      ];
    };

    facter = {
      reportPath = ./facter.json;
    };

    hardware = {
      cpu = {
        intel = {
          updateMicrocode = true;
        };
      };
      enableRedistributableFirmware = true;
    };

    i18n = {
      supportedLocales = [
        "C.UTF-8/UTF-8"
        "de_DE.UTF-8/UTF-8"
        "en_DK.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];

      extraLocaleSettings = {
        LC_COLLATE = "C";
        LC_TIME = "en_DK.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
      };
    };

    programs = {
      nix-ld = {
        enable = true;
      };
    };

    security = {
      sudo = {
        extraConfig = ''
          Defaults:root,%wheel env_keep+=TERMINFO_DIRS
          Defaults:root,%wheel env_keep+=SSH_AUTH_SOCK
        '';
      };
    };

    services = {
      dbus = {
        enable = true;
        implementation = "broker";
      };
      # Do not suspend when closing lid while being charged.
      logind = {
        lidSwitchExternalPower = "ignore";
      };
      openssh = {
        enable = true;
        extraConfig = ''
          AcceptEnv LANG LANGUAGE LC_*
          AcceptEnv COLORTERM TERM TERM_*
        '';
        hostKeys = [
          # Use the persisted SSH host key (required for SOPS to decrypt the secrets)
          {
            path = "/persist/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
        settings = {
          Macs = [
            "hmac-sha2-512"
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
          ];
        };
      };
      timesyncd = {
        enable = true;
      };
    };

    sops = {
      defaultSopsFile = ./secrets.yaml;
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      stateVersion = "25.05";
      switch = {
        enable = false;
        enableNg = true;
      };
    };

    time = {
      timeZone = "Europe/Berlin";
    };
  };
}
