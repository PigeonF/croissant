# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    ;
  cfg = config.croissant.programs.cargo;
  tomlFormat = pkgs.formats.toml { };
in
{
  _file = ./cargo.nix;

  options.croissant.programs = {
    cargo = {
      configure = mkEnableOption "set up cargo";
      settings = mkOption {
        inherit (tomlFormat) type;
        default = { };
        example = literalExpression ''
          {
            alias = {
              t = "nextest run";
            };
          }
        '';
        description = ''
          Configuration written to {file}`$XDG_DATA_HOME/cargo/config.toml`.
          See <https://doc.rust-lang.org/cargo/reference/config.html> for the documentation.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      home.packages = [ pkgs.rustup ];
      xdg.dataFile = {
        "cargo/config.toml" = lib.mkIf (cfg.settings != { }) {
          source = tomlFormat.generate "cargo-config" cfg.settings;
        };
      };
    }
    (lib.mkIf cfg.configure {
      home = {
        shellAliases = {
          "c" = "cargo";
        };

        sessionPath = [ "$CARGO_HOME/bin" ];

        sessionVariables = {
          CARGO_HOME = "$XDG_DATA_HOME/cargo";
        };
      };
    })
  ];
}
