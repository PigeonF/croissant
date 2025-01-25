# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ config, lib, ... }:
{
  _file = ./bash.nix;

  config = {
    environment = {
      variables = {
        HISTFILE = lib.mkDefault "$XDG_DATA_HOME/bash/bash_history";
      };
    };

    systemd.user.tmpfiles.rules =
      let
        replaceHome = builtins.replaceStrings [ "$HOME" ] [ "%h" ];
        replaceEnvVars =
          builtins.replaceStrings
            [ "$XDG_DATA_HOME" ]
            [ (replaceHome config.environment.sessionVariables.XDG_DATA_HOME) ];
        histFile = replaceEnvVars config.environment.variables.HISTFILE;
      in
      [
        "f ${histFile} - - - -"
      ];
  };
}
