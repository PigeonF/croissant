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
  cfg = config.croissant.programs.bash;
in
{
  _file = ./bash.nix;

  options.croissant.programs = {
    bash = {
      enable = mkEnableOption "set up bash";
      extraPackages = mkOption {
        default = [
          pkgs.moreutils
        ];
        example = lib.literalExpression ''
          [
            pkgs.coreutils
          ]
        '';
        type = types.listOf types.package;
        description = ''
          Extra packages that should be installed to the home profile.
        '';
      };
    };
  };

  config = lib.mkMerge [
    {
      programs.bash = {
        inherit (cfg) enable;
        historyFile = "${config.xdg.dataHome}/bash/bash_history";
      };
    }
    (lib.mkIf cfg.enable {
      home = {
        activation = {
          sourceBashFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -s "$HOME/.bash_profile" ]; then
              run rm -f "$HOME/.bash_profile"
              run cat > "$HOME/.bash_profile" <<'EOF'
            if [ -r "$HOME"/${lib.escapeShellArg config.home.file.".bash_profile".target} ]; then
              source "$HOME"/${lib.escapeShellArg config.home.file.".bash_profile".target}
            fi
            EOF
            fi
            if [ ! -s "$HOME/.profile" ]; then
              run rm -f "$HOME/.profile"
              run cat > "$HOME/.profile" <<'EOF'
            if [ -r "$HOME"/${lib.escapeShellArg config.home.file.".profile".target} ]; then
              source "$HOME"/${lib.escapeShellArg config.home.file.".profile".target}
            fi
            EOF
            fi
            if [ ! -s "$HOME/.bashrc" ]; then
              run rm -f "$HOME/.bashrc"
              run cat > "$HOME/.bashrc" <<'EOF'
            if [ -r "$HOME"/${lib.escapeShellArg config.home.file.".bashrc".target} ]; then
              source "$HOME"/${lib.escapeShellArg config.home.file.".bashrc".target}
            fi
            EOF
            fi
          '';
        };

        file = {
          ".bash_profile" = {
            target = ".config/bash/bash_profile";
          };
          ".profile" = {
            target = ".config/bash/profile";
          };
          ".bashrc" = {
            target = ".config/bash/bashrc";
          };
        };

        packages = cfg.extraPackages;
      };
    })
  ];
}
