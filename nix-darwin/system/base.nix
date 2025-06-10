# Base configuration that should be part of every nix-darwin configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkMerge
    mkIf
    ;
  cfg = config.croissant;
in
{
  _file = ./base.nix;

  options = {
    croissant = {
      terminal = {
        enable = mkEnableOption "the terminal base setup" // {
          default = true;
        };
      };
      xdg = {
        enable = mkEnableOption "the XDG base directory setup" // {
          default = true;
        };
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.terminal.enable {
      environment = {
        systemPackages = [
          pkgs.alacritty.terminfo
          pkgs.ncurses
          pkgs.wezterm.terminfo
        ];

        variables = {
          LANG = "en_US.UTF-8";
          LC_COLLATE = "C";
          LC_MONETARY = "en_IE.UTF-8";
          LC_TIME = "en_IE.UTF-8";
        };
      };
    })
    (mkIf cfg.xdg.enable {
      environment = {
        # NOTE(PigeonF): Because variables are set after the system path,
        # there is no way to reference $XDG_BIN_HOME in the systemPath. As such,
        # the PATH is set manually in extraInit.

        # systemPath = [ "\${XDG_BIN_HOME:-$HOME/.local/bin}" ];
        extraInit = ''
          export PATH="''${XDG_BIN_HOME:-$HOME/.local/bin}:$PATH"
        '';

        loginShellInit = ''
          mkdir -p "${config.environment.variables.XDG_BIN_HOME}"
          mkdir -p "${config.environment.variables.XDG_CACHE_HOME}"
          mkdir -p "${config.environment.variables.XDG_CONFIG_HOME}"
          mkdir -p "${config.environment.variables.XDG_DATA_HOME}"
          mkdir -p "${config.environment.variables.XDG_STATE_HOME}"
        '';

        # Replace $HOME/.nix-profile with $XDG_STATE_HOME/nix/profile
        profiles =
          let
            packageUsers = lib.filterAttrs (_: u: u.packages != [ ]) config.users.users;
          in
          lib.mkForce (
            [
              "\${XDG_STATE_HOME:-$HOME/.local/state}/nix/profile"
            ]
            ++ lib.optional (packageUsers != { }) "/etc/profiles/per-user/$USER"
            ++ [
              "/nix/var/nix/profiles/default"
              "/run/current-system/sw"
            ]
          );

        variables = {
          XDG_BIN_HOME = "$HOME/.local/bin";
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_STATE_HOME = "$HOME/.local/state";
        };
      };
    })
  ];
}
