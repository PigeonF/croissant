# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ croissant-lib, ... }:
{
  _file = ./default.nix;

  perSystem =
    { pkgs, ... }:
    {
      legacyPackages.homeConfigurations = {
        root = croissant-lib.mkHomeConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            userName = "root";
          };

          modules = [ ./home.nix ];
        };
      };
    };
}
