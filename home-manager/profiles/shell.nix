_: {
  _file = ./shell.nix;

  config = {
    croissant = {
      programs = {
        atuin.enable = true;
        bat.enable = true;
        eza.enable = true;
        fd.enable = true;
        ripgrep.enable = true;
        starship.enable = true;
        yazi.enable = true;
        zoxide.enable = true;
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
