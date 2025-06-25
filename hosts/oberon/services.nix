{ config, pkgs, ... }:
{
  _file = ./services.nix;

  config = {
    services = {
      gitlab-runner = {
        enable = true;

        clear-docker-cache = {
          enable = false;
        };

        gracefulTermination = true;
        gracefulTimeout = "30s";

        settings = {
          concurrent = 16;
          check_interval = 15;
        };

        services = {
          docker = {
            limit = 8;
            authenticationTokenConfigFile = config.sops.templates."docker-authentication-token.env".path;
            description = "Self-hosted runner for docker executors";
            dockerImage = "docker.io/library/busybox";
            executor = "docker";
            registrationFlags = [
              "--cache-dir /cache"
              "--docker-host unix:///run/podman/podman.sock"
              "--docker-network-mode podman"
              "--docker-volumes /builds"
              "--docker-volumes /cache"
              "--docker-volumes /var/lib/containers"
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
