# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  pkgs,
  ...
}:
{
  _file = ./shell.nix;

  config = {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          eza
          fd
          ncurses
          ripgrep
          ;
      };

      shellAliases = {
        fdA = "fd --hidden --no-ignore";
        fda = "fd --hidden";
        la = "ls -la";
        ls = "eza";
        rgA = "rg --hidden --no-ignore";
        rga = "rg --hidden";
        wget = "wget --hsts-file=${config.xdg.dataHome}/wget-hsts";
      };
    };
  };
}
