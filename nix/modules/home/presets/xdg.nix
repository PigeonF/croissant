# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ config, ... }:
{
  _file = ./xdg.nix;

  config = {
    xdg = {
      enable = true;
      cacheHome = "${config.home.homeDirectory}/.cache";
      configHome = "${config.home.homeDirectory}/.config";
      dataHome = "${config.home.homeDirectory}/.local/share";
      stateHome = "${config.home.homeDirectory}/.local/state";
    };

    home = {
      sessionVariables = {
        LESSHISTFILE = "$XDG_DATA_HOME/lesshst";
      };
    };
  };
}
