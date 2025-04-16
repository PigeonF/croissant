# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ config, pkgs, ... }:
{
  _file = ./services.nix;

  config = {
    services = {
      gitlab-runner = {
        enable = true;

        clear-docker-cache = {
          enable = true;
        };

        gracefulTermination = true;
        gracefulTimeout = "1min 30s";

        settings = {
          concurrent = 8;
        };

        services = {
          docker = {
            authenticationTokenConfigFile = config.sops.templates."docker-authentication-token.env".path;
            description = "Self-hosted runner for docker executors";
            dockerImage = "docker.io/library/busybox";
            executor = "docker";
            registrationFlags = [
              "--cache-dir /cache"
              "--docker-volumes /builds"
              "--docker-volumes /cache"
              "--output-limit 8192"
              "--env FF_NETWORK_PER_BUILD=1"
            ];
          };
        };
      };
    };

    systemd = {
      services = {
        gitlab-runner-clear-docker-cache = {
          path = [ pkgs.bash ];
        };
      };
    };

    sops = {
      templates = {
        "docker-authentication-token.env" = {
          content = ''
            CI_SERVER_URL=https://gitlab.com
            CI_SERVER_TOKEN=${config.sops.placeholder."services/gitlab-runner/docker/authentication-token"}
          '';
        };
      };
      secrets = {
        "services/gitlab-runner/docker/authentication-token" = {
          restartUnits = [ "gitlab-runner.service" ];
        };
      };
    };
  };
}
