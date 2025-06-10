# Base configuration that should be part of every nix-darwin configuration
{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.croissant.nix.linux-builder;
in
{
  _file = ./base.nix;

  options = {
    croissant.nix.linux-builder = {
      enable = mkEnableOption "the linux builder configuration";
    };
  };

  config = mkIf cfg.enable {
    launchd = {
      daemons = {
        linux-builder = {
          serviceConfig = {
            StandardOutPath = "${config.nix.linux-builder.workingDirectory}/stdout.log";
            StandardErrorPath = "${config.nix.linux-builder.workingDirectory}/stderr.log";
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
              diskSize = 4 * 20 * 1024;
              memorySize = 4 * 1024;
            };
            cores = 4;
          };
        };
      };
      settings = {
        trusted-users = [ "@admin" ];
      };
    };
  };
}
