# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./users.nix;

  config = {
    users = {
      users = {
        pigeonf = {
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgBXuwsvHPBuk9OMHraUbEObvyJn8wHw6XKX/1KWAiX"
              ];
            };
          };
        };
        root = {
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIML5ZEA0tlfUTUw0kNol2/iU8RqfIvS0h3A4K17kwcmU"
              ];
            };
          };
        };
      };
    };
  };
}
