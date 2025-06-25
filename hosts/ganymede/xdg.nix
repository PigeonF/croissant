{ config, lib, ... }:
{
  _file = ./xdg.nix;

  config = {
    environment = {
      # NOTE(PigeonF): Set this in extraInit so that the sessionVariables are available.
      extraInit = ''
        export PATH="''${XDG_BIN_HOME:-$HOME/.local/bin}:$PATH"
      '';
      # NOTE(PigeonF): Need to mkForce to remove ~/.nix-profile/
      profiles = lib.mkForce [
        "\${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"
        "/etc/profiles/per-user/$USER"
        "/nix/var/nix/profiles/default"
        "/run/current-system/sw"
      ];
      sessionVariables = {
        XDG_BIN_HOME = "$HOME/.local/bin";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_STATE_HOME = "$HOME/.local/state";
      };
      variables = {
        HISTFILE = "$XDG_STATE_HOME/bash/history";
        LESSHISTFILE = "$XDG_STATE_HOME/less/history";
        XCOMPOSECACHE = "$XDG_CACHE_HOME/X11/xcompose";
      };
    };

    systemd = {
      user = {
        tmpfiles = {
          rules =
            let
              replaceHome = builtins.replaceStrings [ "$HOME" ] [ "%h" ];
              xdgBinHome = replaceHome config.environment.sessionVariables.XDG_BIN_HOME;
              xdgCacheHome = replaceHome config.environment.sessionVariables.XDG_CACHE_HOME;
              xdgConfigHome = replaceHome config.environment.sessionVariables.XDG_CONFIG_HOME;
              xdgDataHome = replaceHome config.environment.sessionVariables.XDG_DATA_HOME;
              xdgStateHome = replaceHome config.environment.sessionVariables.XDG_STATE_HOME;
            in
            [
              "d ${xdgCacheHome} - - - -"
              "d ${xdgConfigHome} - - - -"
              "d ${xdgDataHome} - - - -"
              "d ${xdgStateHome} - - - -"
              "d ${xdgBinHome} - - - -"
            ];
        };
      };
    };
  };
}
