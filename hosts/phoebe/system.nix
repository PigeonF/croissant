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
        pkgs.podman
        pkgs.wezterm.terminfo
      ];
      variables = {
        LANG = "en_US.UTF-8";
        LC_COLLATE = "C";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        # en_DK is not installed on macOS by default, so just fall back to en_GB
        LC_TIME = "en_GB.UTF-8";
      };
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
