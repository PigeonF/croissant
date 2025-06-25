{
  inputs,
  modulesPath,
  ...
}:
{
  _file = ./system.nix;

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  config = {
    boot = {
      binfmt = {
        emulatedSystems = [ "x86_64-linux" ];
      };
      initrd = {
        availableKernelModules = [
          "virtio_pci"
          "xhci_pci"
          "usb_storage"
          "usbhid"
        ];
      };
      loader = {
        grub = {
          efiSupport = true;
          efiInstallAsRemovable = true;
        };
      };
    };

    environment = {
      enableAllTerminfo = true;
      localBinInPath = true;
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
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        # Uses yyyy-mm-dd
        LC_TIME = "en_DK.UTF-8";
      };
    };

    nixpkgs = {
      hostPlatform = "aarch64-linux";
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
      openssh = {
        enable = true;
        extraConfig = ''
          AcceptEnv LANG LANGUAGE LC_*
          AcceptEnv COLORTERM TERM TERM_*
        '';
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
