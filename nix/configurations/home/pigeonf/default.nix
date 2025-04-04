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
        pigeonf = croissant-lib.mkHomeConfiguration {
          inherit pkgs;

          extraSpecialArgs = {
            inherit inputs system;
            userName = "pigeonf";
          };

          modules = [ ./home.nix ];
        };
      };
    };
}
