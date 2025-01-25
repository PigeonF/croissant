# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ config, lib, ... }:
let
  cfg = config.environment;
in
{
  _file = ./xdg.nix;

  config = {
    environment = {
      # NOTE(PigeonF): Deliberately not escapeShellArg because we want to resolve $HOME.
      loginShellInit = ''
        mkdir -p "${cfg.variables.XDG_BIN_HOME}"
        mkdir -p "${cfg.variables.XDG_CACHE_HOME}"
        mkdir -p "${cfg.variables.XDG_CONFIG_HOME}"
        mkdir -p "${cfg.variables.XDG_DATA_HOME}"
        mkdir -p "${cfg.variables.XDG_STATE_HOME}"
      '';

      profiles = lib.mkForce [
        "\${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"
        "/nix/var/nix/profiles/default"
        "/run/current-system/sw"
      ];

      # NOTE(PigeonF): Because variables always comes after the system path,
      # there is no way to reference the XDG_BIN_HOME in the systemPath. As such,
      # the PATH is set manually in extraInit.

      # systemPath = [ "\${XDG_BIN_HOME:-$HOME/.local/bin}" ];
      extraInit = ''
        export PATH="''${XDG_BIN_HOME:-$HOME/.local/bin}:$PATH"
      '';

      variables = {
        XDG_BIN_HOME = lib.mkDefault "$HOME/.local/bin";
        XDG_CACHE_HOME = lib.mkDefault "$HOME/.cache";
        XDG_CONFIG_HOME = lib.mkDefault "$HOME/.config";
        XDG_DATA_HOME = lib.mkDefault "$HOME/.local/share";
        XDG_STATE_HOME = lib.mkDefault "$HOME/.local/state";
      };
    };
  };
}
