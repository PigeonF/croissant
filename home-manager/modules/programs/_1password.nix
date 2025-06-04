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
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs._1password;
in
{
  _file = ./_1password.nix;

  options.croissant.programs = {
    _1password = {
      configure = mkEnableOption "set up 1password";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.configure {
      home.sessionVariablesExtra =
        let
          sshAuthSock =
            if pkgs.stdenv.hostPlatform.isDarwin then
              "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            else
              "${config.home.homeDirectory}/.1password/agent.sock";
        in
        ''
          # Overwrite SSH_AUTH_SOCK unless we are using a SSH connection.
          if [ -z "''${SSH_CLIENT:-}" ] && [ -z "''${SSH_CONNECTION:-}" ] && [ -z "''${SSH_TTY:-}" ]; then
            export SSH_AUTH_SOCK="${sshAuthSock}"
          fi
        '';
    })
  ];
}
