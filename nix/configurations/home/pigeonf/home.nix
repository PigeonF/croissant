# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  userName,
  pkgs,
  ...
}:
{
  config = {
    home = {
      extraOutputsToInstall = [
        "devdoc"
        "doc"
        "man"
      ];
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${userName}" else "/home/${userName}";
      stateVersion = "25.05";
      username = userName;
    };

    croissant = {
      dotfiles = {
        enable = true;
      };
      programs = {
        jujutsu.enable = true;
      };
    };

    programs = {
      home-manager.enable = true;
    };
  };
}
