# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  ...
}:
{
  _file = ./users.nix;

  config = {
    environment = {
      persistence = {
        "/persist" = {
          users =
            let
              commonDirectories = [
                {
                  directory = ".ssh";
                  mode = "0700";
                }
              ];
              xdgDirectories = [
                ".config"
                ".local/bin"
                ".local/share"
              ];
            in
            {
              pigeonf = {
                directories =
                  commonDirectories
                  ++ xdgDirectories
                  ++ [
                    ".vscodium-server"
                    "code"
                    "downloads"
                  ];
                files = [
                  ".bash_profile"
                  ".bashrc"
                  ".profile"
                  ".zshenv"
                ];
              };
              root = {
                home = "/root";
                directories = commonDirectories ++ xdgDirectories;
              };
            };
        };
        "/cache" = {
          users =
            let
              xdgDirectories = [
                ".cache"
                ".local/state"
              ];
            in
            {
              pigeonf = {
                directories = xdgDirectories;
              };
              root = {
                home = "/root";
                directories = xdgDirectories;
              };
            };
        };
      };
    };

    sops = {
      secrets = {
        "root/password" = {
          neededForUsers = true;
        };
        "pigeonf/password" = {
          neededForUsers = true;
        };
      };
    };

    users = {
      mutableUsers = false;
      users = {
        root = {
          hashedPasswordFile = config.sops.secrets."root/password".path;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOZWVYrGZVFnvwpJLBWSD/y3HnTU++eJez5Ip2WvQeNe"
          ];
        };

        pigeonf = {
          isNormalUser = true;
          hashedPasswordFile = config.sops.secrets."pigeonf/password".path;
          extraGroups = [ "wheel" ];
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSGbm3QEVQFhYqJM29rQ6WibpQr613KgxoYTr/QvztV"
          ];
        };
      };
    };
  };
}
