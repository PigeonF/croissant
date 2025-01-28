# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ croissant-lib, inputs, ... }:
{
  _file = ./default.nix;

  perSystem =
    { pkgs, system, ... }:
    {
      homeConfigurations = {
        root = croissant-lib.mkHomeConfiguration {
          inherit inputs pkgs system;

          extraSpecialArgs = {
            userName = "root";
          };

          modules = [ ./home.nix ];
        };
      };
    };
}
