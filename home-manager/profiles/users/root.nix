{ croissantModulesPath, ... }:
{
  _file = ./root.nix;

  imports = [
    (croissantModulesPath + "/profiles/base.nix")
    (croissantModulesPath + "/profiles/shell.nix")
  ];

  config = {
    croissant = {
      programs = {
        git.enable = true;
        helix.enable = true;
      };
    };
  };
}
