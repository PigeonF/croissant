# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ config, lib, ... }:
{
  _file = ./bash.nix;

  config = {

    environment = {
      sessionVariables = {
        XDG_CACHE_HOME = lib.mkDefault "$HOME/.cache";
        XDG_CONFIG_HOME = lib.mkDefault "$HOME/.config";
        XDG_DATA_HOME = lib.mkDefault "$HOME/.local/share";
        XDG_STATE_HOME = lib.mkDefault "$HOME/.local/state";

        XDG_BIN_HOME = lib.mkDefault "$HOME/.local/bin";
        PATH = [
          "$XDG_BIN_HOME"
        ];
      };

      variables = {
        HISTFILE = lib.mkDefault "$XDG_DATA_HOME/bash/bash_history";
      };
    };

    systemd.user.tmpfiles.rules =
      let
        replaceHome = builtins.replaceStrings [ "$HOME" ] [ "%h" ];
        replaceEnvVars =
          builtins.replaceStrings
            [
              "$HOME"
              "$XDG_CACHE_HOME"
              "$XDG_CONFIG_HOME"
              "$XDG_DATA_HOME"
              "$XDG_RUNTIME_DIR"
              "$XDG_STATE_HOME"
            ]
            [
              "%h"
              "%C"
              (replaceHome config.environment.sessionVariables.XDG_CONFIG_HOME)
              (replaceHome config.environment.sessionVariables.XDG_DATA_HOME)
              "%r"
              "%S"
            ];
        xdgCacheHome = replaceEnvVars config.environment.sessionVariables.XDG_CACHE_HOME;
        xdgConfigHome = replaceEnvVars config.environment.sessionVariables.XDG_CONFIG_HOME;
        xdgDataHome = replaceEnvVars config.environment.sessionVariables.XDG_DATA_HOME;
        xdgStateHome = replaceEnvVars config.environment.sessionVariables.XDG_STATE_HOME;
        xdgBinHome = replaceEnvVars config.environment.sessionVariables.XDG_BIN_HOME;
        histFile = replaceEnvVars config.environment.variables.HISTFILE;
      in
      [
        "d ${xdgCacheHome} - - - -"
        "d ${xdgConfigHome} - - - -"
        "d ${xdgDataHome} - - - -"
        "d ${xdgStateHome} - - - -"
        "d ${xdgBinHome} - - - -"
        "f ${histFile} - - - -"
      ];
  };
}
