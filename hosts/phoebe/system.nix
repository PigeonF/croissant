# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  inputs,
  pkgs,
  ...
}:
{
  _file = ./system.nix;

  config = {
    environment = {
      pathsToLink = [ "/share/terminfo" ];
      systemPackages = [
        pkgs.alacritty.terminfo
        pkgs.wezterm.terminfo
      ];
    };

    launchd = {
      daemons = {
        startup = {
          serviceConfig = {
            LaunchOnlyOnce = true;
            ProgramArguments = [
              "/usr/sbin/sysctl"
              "-w"
              "net.inet.tcp.delayed_ack=0"
            ];
            RunAtLoad = true;
          };
        };
      };
    };

    networking = {
      hostName = "phoebe";
      computerName = "Phoebe Server";
    };

    sops = {
      defaultSopsFile = ./secrets.yaml;
    };

    system = {
      configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;
      stateVersion = 5;
    };
  };
}
