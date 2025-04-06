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
          directories = [ "/home/pigeonf" ];
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
              # XXX(PigeonF): Impermanence cannot restore the symlinks in `files`, which is why we have to store the full parent directory.
              #               I dont' think this can be solved in `impermanence` unless one introduces a special "restore the contents of this file as symlink path" type.
              #               The easiest way to solve this is probably to have bash and zsh respect the xdg spec, so that we only have to care about the `.config/` folder.
              # pigeonf = {
              #   directories =
              #     commonDirectories
              #     ++ xdgDirectories
              #     ++ [
              #       ".vscodium-server"
              #       "code"
              #       "downloads"
              #     ];
              #   files = [
              #     ".bash_profile"
              #     ".bashrc"
              #     ".profile"
              #     ".zshenv"
              #   ];
              # };
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
              # pigeonf = {
              #   directories = xdgDirectories;
              # };
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
