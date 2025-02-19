# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  croissantPresetsPath,
  ...
}:
{
  _file = ./configuration.nix;

  imports = [
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/darwin/xdg.nix"
    inputs.lix-modules.nixosModules.default
  ];

  config = {
    homebrew = {
      enable = true;
      casks = [
        "1password"
        "docker"
      ];
    };

    nix = {
      linux-builder = {
        enable = true;
        ephemeral = true;
        maxJobs = 4;

        config = {
          virtualisation = {
            darwin-builder = {
              diskSize = 40 * 1024;
              memorySize = 8 * 1024;
            };
            cores = 6;
          };
        };
      };

      settings = {
        trusted-users = [ "@admin" ];
      };
    };

    launchd.daemons.linux-builder = {
      serviceConfig = {
        StandardOutPath = "/var/log/darwin-builder.log";
        StandardErrorPath = "/var/log/darwin-builder.log";
      };
    };

    networking = {
      computerName = "kamino";
    };

    system = {
      stateVersion = 5;
    };
  };
}
