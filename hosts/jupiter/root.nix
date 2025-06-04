# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ inputs, ... }:
{
  _file = ./root.nix;

  imports = [
    inputs.self.homeManagerModules.root
    inputs.self.homeManagerModules.programs.zsh
  ];

  config = {
    croissant = {
      programs = {
        zsh.configure = true;
      };
    };

    home = {
      stateVersion = "25.05";
      username = "root";
      homeDirectory = "/var/root";
    };
  };
}
