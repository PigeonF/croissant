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
        "pigeonf/password" = {
          neededForUsers = true;
        };
      };
    };

    users = {
      mutableUsers = false;
      users = {
        pigeonf = {
          isNormalUser = true;
          hashedPasswordFile = config.sops.secrets."pigeonf/password".path;
          extraGroups = [
            "docker"
            "wheel"
          ];
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILYJE84WTAqpMwxRS1jbA/ZK+KpCxgf/sO4zNWyw4D/N"
              ];
            };
          };
        };

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
