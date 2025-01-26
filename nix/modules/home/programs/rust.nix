# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  pkgs,
  system,
  croissant-lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.croissant.programs.rust;
in
{
  _file = ./rust.nix;

  options.croissant.programs = {
    rust = {
      enable = mkEnableOption "set up rust";
      fastLinker = mkEnableOption "use a faster linker by default" // {
        default = true;
      };
      cargoConfig = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Contents of the $CARGO_HOME/config.toml file.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.cargoConfig != "") {
      home = {
        file."${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.dataHome}/cargo/config.toml".text =
          cfg.cargoConfig;
      };
    })
    (lib.mkIf cfg.enable {
      home = {
        packages = builtins.attrValues {
          inherit (pkgs)
            cargo-audit
            cargo-binstall
            cargo-bloat
            cargo-deny
            cargo-fuzz
            cargo-hack
            cargo-nextest
            cargo-show-asm
            rustup
            ;
        };

        shellAliases = {
          "c" = "cargo";
        };

        sessionPath = [ "$CARGO_HOME/bin" ];

        sessionVariables = {
          CARGO_HOME = "${config.xdg.dataHome}/cargo";
          RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
        };
      };

      croissant = {
        programs = {
          rust = {
            cargoConfig = ''
              [alias]
              t = "nextest run"
            '';
          };
        };
      };
    })
    (lib.mkIf (cfg.fastLinker && pkgs.stdenv.hostPlatform.isLinux) {
      croissant.programs.rust.cargoConfig = ''
        [target.${croissant-lib.systemToRustPlatform system}]
        linker = "${lib.getExe pkgs.clang}"
        rustflags = ["-C", "link-arg=--ld-path=${lib.getExe pkgs.mold}"]
      '';
      home = {
        packages = builtins.attrValues { inherit (pkgs) clang mold; };
      };
    })
  ];
}
