# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  croissantPresetsPath,
  lib,
  pkgs,
  userName,
  ...
}:
{
  imports = [
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/shell.nix"
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

      sessionVariablesExtra = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin ''

        # Overwrite SSH_AUTH_SOCK unless we are using a SSH connection.
        if [ -z "''${SSH_CLIENT:-}" ] && [ -z "''${SSH_CONNECTION:-}" ] && [ -z "''${SSH_TTY:-}" ]; then
          export SSH_AUTH_SOCK="${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        fi
      '';

      stateVersion = "25.05";
      username = userName;
    };

    croissant = {
      dotfiles = {
        enable = true;
      };
      programs = {
        atuin.enable = true;
        bash.enable = true;
        ghq.enable = true;
        git.enable = true;
        helix.enable = true;
        jujutsu.enable = true;
        rust.enable = true;
        starship.enable = true;
        zellij.enable = true;
        zsh.enable = true;
      };
    };

    programs = {
      home-manager.enable = true;
      zoxide.enable = true;
    };
  };
}
