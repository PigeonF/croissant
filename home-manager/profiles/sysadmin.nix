{ pkgs, ... }:
{
  _file = ./sysadmin.nix;

  config = {
    croissant = {
      programs = {
        btop.enable = true;
      };
    };

    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          dust
          nix-tree
          ;
      };
    };
  };
}
