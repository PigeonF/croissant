# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  croissantPresetsPath,
  inputs,
  ...
}:
{
  _file = ./configuration.nix;

  imports = [
    ./homepage-dashboard.nix
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/nixos/bash.nix"
    "${croissantPresetsPath}/nixos/network.nix"
    "${croissantPresetsPath}/nixos/users.nix"
    "${croissantPresetsPath}/nixos/xdg.nix"
    "${croissantPresetsPath}/openssh.nix"
    inputs.lix-modules.nixosModules.default
    inputs.microvm.nixosModules.microvm
    inputs.self.nixosModules.microvm-vm
    inputs.sops-nix.nixosModules.sops
  ];

  config = {
    microvm = {
      mem = 8192;
      vcpu = 4;
    };

    networking = {
      hostName = "raxus";
    };

    sops = {
      defaultSopsFile = ./secrets.yaml;
      secrets = { };
    };

    services = {
      openssh.enable = true;

      nginx = {
        enable = true;

        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;

        commonHttpConfig = ''
          log_format main '$remote_addr - $remote_user [$time_local] '
                          '{$host} "$request" $status $body_bytes_sent '
                          '"$http_referer" "$http_user_agent"';

          access_log syslog:server=unix:/dev/log main;

          set_real_ip_from ${config.croissant.microvms.host.ipv4};
          set_real_ip_from ${config.croissant.microvms.host.ipv6};

          real_ip_header proxy_protocol;
        '';

        defaultListen = [
          {
            addr = "0.0.0.0";
            port = 80;
            proxyProtocol = true;
          }
          {
            addr = "[::0]";
            port = 80;
            proxyProtocol = true;
          }
        ];
      };
    };

    system = {
      stateVersion = "25.05";
    };

    users = {
      users.root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSGbm3QEVQFhYqJM29rQ6WibpQr613KgxoYTr/QvztV"
        ];
      };
    };
  };
}
