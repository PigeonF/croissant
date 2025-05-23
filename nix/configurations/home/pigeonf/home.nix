# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  croissantPresetsPath,
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
    croissant = {
      dotfiles = {
        enable = true;
      };
      programs = {
        atuin.enable = true;
        bash.enable = true;
        containers.enable = true;
        ghq.enable = true;
        git.enable = true;
        helix.enable = true;
        jujutsu.enable = true;
        nushell.enable = true;
        rust.enable = true;
        starship.enable = true;
        vscodium.enable = true;
        yazi.enable = true;
        zellij.enable = true;
        zsh.enable = true;
      };
    };

    home = {
      extraOutputsToInstall = [
        "devdoc"
        "doc"
        "man"
      ];
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${userName}" else "/home/${userName}";

      sessionVariablesExtra =
        let
          sshAuthSock =
            if pkgs.stdenv.hostPlatform.isDarwin then
              "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            else
              "${config.home.homeDirectory}/.1password/agent.sock";
        in
        ''

          # Overwrite SSH_AUTH_SOCK unless we are using a SSH connection.
          if [ -z "''${SSH_CLIENT:-}" ] && [ -z "''${SSH_CONNECTION:-}" ] && [ -z "''${SSH_TTY:-}" ]; then
            export SSH_AUTH_SOCK="${sshAuthSock}"
          fi
        '';

      stateVersion = "25.05";
      username = userName;
    };

    nixpkgs = {
      config = {
        allowBroken = true;
      };
    };

    programs = {
      home-manager.enable = true;
      zoxide.enable = true;
    };
  };
}
