# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  userName,
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
      homeDirectory = "/root";
      stateVersion = "25.05";
      username = userName;
    };

    programs.home-manager.enable = true;
  };
}
