# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ lib, ... }:
{
  _file = ./users.nix;

  config = {
    services = {
      userborn.enable = lib.mkDefault true;
    };

    users = {
      mutableUsers = lib.mkDefault false;
    };
  };
}
