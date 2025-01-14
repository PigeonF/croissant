# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./configuration.nix;

  config = {
    networking = {
      hostName = "serenno";
    };

    services = {
      openssh.enable = true;
    };

    system = {
      stateVersion = "25.05";
    };

    users = {
      users.root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSGbm3QEVQFhYqJM29rQ6WibpQr613KgxoYTr/QvztV"
      ];
    };
  };
}
