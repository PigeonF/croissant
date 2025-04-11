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
    literalExpression
    mkEnableOption
    mkOption
    ;
  cfg = config.croissant.programs.rust;
  cfgCargo = config.croissant.programs.cargo;
  tomlFormat = pkgs.formats.toml { };
in
{
  _file = ./rust.nix;

  options.croissant.programs = {
    cargo = {
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
    rust = {
      enable = mkEnableOption "set up rust";
      fastLinker = mkEnableOption "use a faster linker by default" // {
        default = true;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      xdg.dataFile = {
        "cargo/config.toml" = lib.mkIf (cfgCargo.settings != { }) {
          source = tomlFormat.generate "cargo-config" cfgCargo.settings;
        };
      };
    })
    (lib.mkIf cfg.enable {
      home = {
        packages = builtins.attrValues (
          {
            inherit (pkgs)
              cargo-audit
              cargo-binstall
              cargo-bloat
              cargo-criterion
              cargo-deny
              cargo-dist
              cargo-flamegraph
              cargo-fuzz
              cargo-hack
              cargo-insta
              cargo-mutants
              cargo-nextest
              cargo-show-asm
              cargo-xwin
              cargo-zigbuild
              release-plz
              rustup
              # Documentation
              mdbook
              gnuplot
              # Command runner(s)
              just
              # Debugging
              lldb
              ;
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
            inherit (pkgs) rr;
          }
        );

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
          cargo = {
            settings = {
              alias = {
                t = "nextest run";
              };
            };
          };
        };
      };
    })
    (lib.mkIf (cfg.fastLinker && pkgs.stdenv.hostPlatform.isLinux) {
      croissant = {
        programs = {
          cargo = {
            settings = {
              target = {
                "${croissant-lib.systemToRustPlatform system}" = {
                  linker = "${lib.getExe pkgs.clang}";
                  rustflags = [
                    "-C"
                    "link-arg=--ld-path=${lib.getExe pkgs.mold}"
                  ];
                };
              };
            };
          };
        };
      };

      home = {
        packages = builtins.attrValues { inherit (pkgs) clang mold; };
      };
    })
  ];
}
