# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ inputs, ... }:
{
  imports = [
    # inputs.nix-rosetta-builder.darwinModules.default
    inputs.self.darwinModules.base
    # inputs.self.darwinModules.gitlab-tart-executor
    inputs.self.darwinModules.homebrew
    inputs.self.darwinModules.nix
    inputs.sops-nix.darwinModules.sops
  ];

  config = {
    # croissant = {
    #   services = {
    #     gitlab-tart-executor = {
    #       user = "pigeonf";
    #     };
    #   };
    # };

    homebrew = {
      brews = [ "lima" ];
    };

    # nix-rosetta-builder = {
    #   onDemand = true;
    # };

    services = {
      gitlab-runner.enable = true;
    };

    system = {
      primaryUser = "pigeonf";
    };

    users = {
      users = {
        pigeonf = {
          openssh.authorizedKeys.keyFiles = [
            (../../../dotfiles/ssh/.ssh/keys.d + "/pigeonf@jupiter.pub")
          ];
        };
        root = {
          openssh.authorizedKeys.keyFiles = [
            (../../../dotfiles/ssh/.ssh/keys.d + "/root@jupiter.pub")
          ];
        };
      };
    };
  };
}
