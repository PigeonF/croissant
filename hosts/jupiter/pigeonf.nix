# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ inputs, ... }:
{
  _file = ./pigeonf.nix;

  imports = [
    inputs.self.homeManagerModules.containers
    inputs.self.homeManagerModules.dotfiles
    inputs.self.homeManagerModules.pigeonf
    inputs.self.homeManagerModules.programs._1password
    inputs.self.homeManagerModules.programs.nushell
    inputs.self.homeManagerModules.programs.vscodium
    inputs.self.homeManagerModules.programs.zsh
    inputs.self.homeManagerModules.rust
    inputs.self.homeManagerModules.sysadmin
  ];

  config = {
    croissant = {
      dotfiles.enable = true;

      programs = {
        _1password.configure = true;
        vscodium.configure = true;
        zsh.configure = true;
      };
    };

    home = {
      stateVersion = "25.05";
      username = "pigeonf";
      homeDirectory = "/Users/pigeonf";
    };
  };
}
