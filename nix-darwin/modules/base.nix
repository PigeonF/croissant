# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  pkgs,
  lib,
  ...
}:
let
  vars = config.environment.variables;
in
{
  _file = ./base.nix;

  config = {
    environment = {
      # NOTE(PigeonF): Because variables are set after the system path,
      # there is no way to reference $XDG_BIN_HOME in the systemPath. As such,
      # the PATH is set manually in extraInit.
      # systemPath = [ "\${XDG_BIN_HOME:-$HOME/.local/bin}" ];
      extraInit = ''
        export PATH="''${XDG_BIN_HOME:-$HOME/.local/bin}:$PATH"
      '';

      loginShellInit = ''
        mkdir -p "${vars.XDG_BIN_HOME}"
        mkdir -p "${vars.XDG_CACHE_HOME}"
        mkdir -p "${vars.XDG_CONFIG_HOME}"
        mkdir -p "${vars.XDG_DATA_HOME}"
        mkdir -p "${vars.XDG_STATE_HOME}"
      '';

      pathsToLink = [ "/share/terminfo" ];

      profiles = lib.mkForce [
        "\${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"
        "/nix/var/nix/profiles/default"
        "/run/current-system/sw"
      ];

      systemPackages = [
        pkgs.alacritty.terminfo
        pkgs.wezterm.terminfo
      ];

      variables = {
        LANG = "en_US.UTF-8";
        LC_COLLATE = "C";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_TIME = "en_GB.UTF-8"; # en_DK is not installed on macOS by default, so just fall back to en_GB
        XDG_BIN_HOME = "$HOME/.local/bin";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
      };
    };
  };
}
