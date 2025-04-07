# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  croissantPresetsPath,
  pkgs,
  userName,
  ...
}:
{
  imports = [
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/shell.nix"
    "${croissantPresetsPath}/sysadmin.nix"
    "${croissantPresetsPath}/xdg.nix"
  ];

  config = {
    home = {
      extraOutputsToInstall = [
        "devdoc"
        "doc"
        "man"
      ];
      homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/var/${userName}" else "/${userName}";
      stateVersion = "25.05";
      username = userName;
    };

    croissant = {
      programs = {
        bash.enable = true;
        git.enable = true;
        helix.enable = true;
        starship.enable = true;
        zsh.enable = true;
      };
    };

    programs = {
      home-manager.enable = true;
    };
  };
}
