# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
_: {
  _file = ./shell.nix;

  imports = [
    ./programs/atuin.nix
    ./programs/bat.nix
    ./programs/eza.nix
    ./programs/fd.nix
    ./programs/ripgrep.nix
    ./programs/starship.nix
    ./programs/yazi.nix
    ./programs/zoxide.nix
  ];

  config = {
    croissant = {
      programs = {
        atuin.configure = true;
        eza.configure = true;
        fd.configure = true;
        nix.configure = true;
        ripgrep.configure = true;
      };
    };

    home = {
      extraOutputsToInstall = [ "man" ];

      sessionVariables = {
        LESSHISTFILE = "$XDG_DATA_HOME/lesshst";
      };
      shellAliases = {
        wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      };
    };
  };
}
