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
    "${croissantPresetsPath}/bash.nix"
    "${croissantPresetsPath}/network.nix"
    "${croissantPresetsPath}/nix.nix"
    "${croissantPresetsPath}/openssh.nix"
    "${croissantPresetsPath}/users.nix"
    inputs.microvm.nixosModules.microvm
    inputs.self.nixosModules.microvm-vm
  ];

  config = {
    microvm = {
      mem = 8192;
      vcpu = 4;
    };

    networking = {
      hostName = "raxus";
    };

    services = {
      openssh.enable = true;
      nginx = {
        enable = true;
        virtualHosts.default = {
          serverName = "_";
          locations."/" = {
            return = "200 '<html><body>It works</body></html>'";
            extraConfig = ''
              default_type text/html;
            '';
          };
        };
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
