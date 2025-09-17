{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  cfg = config.croissant.rust;
  systemToRustPlatform =
    system:
    if system == "aarch64-darwin" then
      "aarch64-apple-darwin"
    else if system == "aarch64-linux" then
      "aarch64-unknown-linux-gnu"
    else if system == "x86_64-darwin" then
      "x86_64-apple-darwin"
    else if system == "x86_64-linux" then
      "x86_64-unknown-linux-gnu"
    else
      abort "Cannot convert ${system} to rust platform";
in
{
  _file = ./rust.nix;

  options.croissant = {
    rust = {
      enable = mkEnableOption "set up rust development";

      extraPackages = mkOption {
        default = [
          pkgs.cargo-audit
          pkgs.cargo-auditable
          pkgs.cargo-binstall
          pkgs.cargo-bloat
          pkgs.cargo-crev
          pkgs.cargo-criterion
          pkgs.cargo-cyclonedx
          pkgs.cargo-deny
          pkgs.cargo-dist
          pkgs.cargo-flamegraph
          pkgs.cargo-fuzz
          pkgs.cargo-hack
          pkgs.cargo-insta
          pkgs.cargo-mutants
          pkgs.cargo-nextest
          pkgs.cargo-release
          pkgs.cargo-semver-checks
          pkgs.cargo-show-asm
          pkgs.cargo-vet
          pkgs.cargo-xwin
          pkgs.cargo-zigbuild
          pkgs.lldb
        ] ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.rr;
        example = lib.literalExpression ''
          [
            pkgs.cargo-hack
          ]
        '';
        type = types.listOf types.package;
        description = ''
          Extra packages that should be installed to the home profile.
        '';
      };

      fastLinker = mkEnableOption "use a faster linker by default" // {
        default = pkgs.stdenv.hostPlatform.isLinux;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      croissant.programs.cargo = {
        enable = true;
        settings = {
          alias = {
            t = "nextest run";
          };
        };
      };

      home = {
        packages = [ pkgs.rustup ] ++ cfg.extraPackages;
        sessionVariables = {
          RUSTUP_HOME = "$XDG_DATA_HOME/rustup";
        };
      };
    })
    (lib.mkIf (cfg.enable && cfg.fastLinker) {
      croissant = {
        programs = {
          cargo = {
            settings = {
              target = {
                "${systemToRustPlatform pkgs.system}" = {
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
        packages = [
          pkgs.clang
          pkgs.mold
        ];
      };
    })
  ];
}
