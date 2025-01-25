# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  userName,
  pkgs,
  ...
}:
{
  imports = [
    inputs.self.homeModules.dotfiles
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
        dotterArgs = [
          "--local-config"
          (pkgs.writeText "local.toml" ''
            packages = []
          '')
        ];
      };
    };

    programs.home-manager.enable = true;
  };
}
