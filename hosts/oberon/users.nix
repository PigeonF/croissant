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
    sops = {
      secrets = {
        "root/password" = {
          neededForUsers = true;
        };
      };
    };

    users = {
      mutableUsers = false;
      users = {
        root = {
          hashedPasswordFile = config.sops.secrets."root/password".path;
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINCa4WBVKpmqTbmeu+0HMHFuSS+xW+kpLRaFxu8xEWr2"
              ];
            };
          };
        };
      };
    };
  };
}
