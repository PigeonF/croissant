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
    mkEnableOption
    ;
  cfg = config.croissant.nix;
in
{
  _file = ./nix.nix;

  options.croissant.nix = {
    linux-builder = {
      enable = mkEnableOption "set up linux builder";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.linux-builder.enable {
      launchd = {
        daemons = {
          linux-builder = {
            serviceConfig = {
              StandardOutPath = "/var/log/nix-linux-builder.stdout.log";
              StandardErrorPath = "/var/log/nix-linux-builder.stderr.log";
            };
          };
        };
      };

      nix = {
        linux-builder = {
          enable = true;
          ephemeral = true;
          maxJobs = 2;

          config = {
            virtualisation = {
              darwin-builder = {
                diskSize = 2 * 20 * 1024;
                memorySize = 2 * 1024;
              };
              cores = 2;
            };
          };
        };
      };
    })
    {
      nix = {
        channel = {
          enable = false;
        };
        package = pkgs.nixVersions.stable;
        settings = {
          extra-experimental-features = [
            "flakes"
            "nix-command"
            "no-url-literals"
          ];
          sandbox = true;
          trusted-users = [
            "@admin"
            "@wheel"
          ];
          use-xdg-base-directories = true;
        };
      };
    }
  ];
}
