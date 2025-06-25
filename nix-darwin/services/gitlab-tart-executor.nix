# Enable gitlab runner macOS VMs via gitlab-tart-executor.
#
# Requires the sops-nix module.
{ config, lib, ... }:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.croissant.services.gitlab-tart-executor;
in
{
  _file = ./gitlab-tart-executor.nix;

  options = {
    croissant.services.gitlab-tart-executor = {
      enable = mkEnableOption "the gitlab-tart-executor for the gitlab-runner";

      sops-secret = mkOption {
        type = types.nullOr types.str;
        description = ''
          The secret to use for the tart GitLab runner authentication token.
        '';
        default = "gitlab-runner/tart/authentication-token";
      };

      user = mkOption {
        type = types.str;
        description = ''
          The user under which the gitlab tart executor should run.

          In order for the VMs to work, this has to be a normal user.
        '';
        default = config.system.primaryUser;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.hasAttr cfg.user config.users.users;
        message = ''`croissant.services.gitlab-tart-executor.user` not found in `users.users`'';
      }
      {
        assertion = config.services.gitlab-runner.enable;
        message = ''`services.gitlab-runner.enable` has to be activated for gitlab-tart-executor to work'';
      }
      {
        assertion = config ? sops;
        message = ''`croissant.services.gitlab-tart-executor` requires the `sops-nix.darwinModules.sops` module'';
      }
    ];

    homebrew = {
      brews = [ "cirruslabs/cli/gitlab-tart-executor" ];
    };

    launchd = {
      daemons = {
        gitlab-runner =
          let
            home =
              if config.users.users.${cfg.user}.home != null then
                config.users.users.${cfg.user}.home
              else
                "/Users/${cfg.user}";
            stateDir = "${home}/.local/state";
            serviceDir = "${stateDir}/gitlab-runner";
          in
          {
            environment = {
              HOME = lib.mkForce serviceDir;
            };
            serviceConfig = {
              StandardOutPath = "${serviceDir}/.gitlab-runner/stdout.log";
              StandardErrorPath = "${serviceDir}/.gitlab-runner/stderr.log";

              # NOTE(PigeonF): We have to run as the normal user for tart to work.
              # Since tart runs actual VMs, I am not too worried about the account having root access.
              GroupName = lib.mkForce "admin";
              UserName = lib.mkForce cfg.user;
              WorkingDirectory = lib.mkForce "${serviceDir}/.gitlab-runner";
            };
          };
      };
    };

    services = {
      gitlab-runner = {
        services = {
          tart =
            let
              homebrewPrefix = config.homebrew.brewPrefix;
            in
            {
              limit = 3;
              authenticationTokenConfigFile =
                config.sops.templates."services/gitlab-runner/tart/authentication-token.env".path;
              executor = "custom";
              registrationFlags = [
                "--custom-config-exec ${homebrewPrefix}/gitlab-tart-executor"
                "--custom-config-args config"
                "--custom-prepare-exec ${homebrewPrefix}/gitlab-tart-executor"
                "--custom-prepare-args prepare"
                "--custom-run-exec ${homebrewPrefix}/gitlab-tart-executor"
                "--custom-run-args run"
                "--custom-cleanup-exec ${homebrewPrefix}/gitlab-tart-executor"
                "--custom-cleanup-args cleanup"
              ];
            };
        };
      };
    };

    sops = {
      templates = {
        "services/gitlab-runner/tart/authentication-token.env" = {
          content = ''
            CI_SERVER_URL=https://gitlab.com
            CI_SERVER_TOKEN=${config.sops.placeholder.${cfg.sops-secret}}
          '';
          group = "admin";
          owner = cfg.user;
        };
      };
      secrets = {
        "${cfg.sops-secret}" = { };
      };
    };
  };
}
