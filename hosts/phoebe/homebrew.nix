# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./homebrew.nix;

  config = {
    homebrew = {
      enable = true;
      casks = [
        "crystalfetch"
        "docker"
        "utm"
      ];
    };
  };
}
