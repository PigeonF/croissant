# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ config, lib, ... }:
{
  _file = ./services.nix;

  config = {
    homebrew = {
      brews = [ "cirruslabs/cli/gitlab-tart-executor" ];
    };

    launchd = {
      daemons = {
        gitlab-runner = {
          environment = {
            HOME = lib.mkForce "/Users/pigeonf/";
          };
          serviceConfig = {
            StandardOutPath = "/Users/pigeonf/.gitlab-runner/stdout.log";
            StandardErrorPath = "/Users/pigeonf/.gitlab-runner/stderr.log";

            # NOTE(PigeonF): We have to run as the normal user for tart to work.
            # Since tart runs actual VMs, I am not too worried about the account having root access.
            GroupName = lib.mkForce "admin";
            UserName = lib.mkForce "pigeonf";
            WorkingDirectory = lib.mkForce config.users.users.pigeonf.home;
          };
        };
      };
    };

    services = {
      gitlab-runner = {
        enable = true;
        services = {
          tart = {
            authenticationTokenConfigFile = config.sops.templates."tart-authentication-token.env".path;
            executor = "custom";
            registrationFlags = [
              "--custom-config-exec /opt/homebrew/bin/gitlab-tart-executor"
              "--custom-config-args config"
              "--custom-prepare-exec /opt/homebrew/bin/gitlab-tart-executor"
              "--custom-prepare-args prepare"
              "--custom-run-exec /opt/homebrew/bin/gitlab-tart-executor"
              "--custom-run-args run"
              "--custom-cleanup-exec /opt/homebrew/bin/gitlab-tart-executor"
              "--custom-cleanup-args cleanup"
            ];
          };
        };
      };
    };

    sops = {
      templates = {
        "tart-authentication-token.env" = {
          content = ''
            CI_SERVER_URL=https://gitlab.com
            CI_SERVER_TOKEN=${config.sops.placeholder."gitlab-runner/tart/authentication-token"}
          '';
          group = "admin";
          owner = "pigeonf";
        };
      };
      secrets = {
        "gitlab-runner/tart/authentication-token" = { };
      };
    };
  };
}
