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
    "${croissantPresetsPath}/xdg.nix"
  ];

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
        git.enable = true;
        helix.enable = true;
        jujutsu.enable = true;
      };
    };

    programs = {
      home-manager.enable = true;
      # Make sure to add the home manager variables to the path.
      zsh.enable = true;
    };
  };
}
