# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ inputs, pkgs, ... }:
let
  userName = "pigeonf";
in
{
  _file = ./pigeonf.nix;

  imports = [
    inputs.self.homeManagerModules.pigeonf
    inputs.self.homeManagerModules.programs._1password
    inputs.self.homeManagerModules.programs.bash
  ];

  config = {
    croissant = {
      programs = {
        _1password.configure = true;
        bash.configure = true;
      };
    };

    home = {
      stateVersion = "25.05";
      username = userName;
      homeDirectory =
        if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${userName}" else "/home/${userName}";
    };
  };
}
