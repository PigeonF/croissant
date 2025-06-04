# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ inputs, pkgs, ... }:
let
  userName = "root";
in
{
  _file = ./root.nix;

  imports = [
    inputs.self.homeManagerModules.root
    inputs.self.homeManagerModules.programs.bash
  ];

  config = {
    croissant = {
      programs = {
        bash.configure = true;
      };
    };

    home = {
      stateVersion = "25.05";
      username = userName;
      homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/var/root" else "/root";
    };
  };
}
