# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
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
    };

    i18n = {
      supportedLocales = [
        "en_US.UTF-8/UTF-8"
      ];
    };

    nixpkgs = {
      hostPlatform = "x86_64-linux";
    };

    services = {
      openssh = {
        enable = true;
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
