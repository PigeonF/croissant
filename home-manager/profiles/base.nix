{ pkgs, ... }:
{
  _file = ./base.nix;

  config = {
    croissant = {
      programs = {
        home-manager.enable = true;
        nix.enable = true;
      };
    };

    home = {
      packages = [ pkgs.ncurses ];
    };

    news = {
      display = "silent";
    };
  };
}
