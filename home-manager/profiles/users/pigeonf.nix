{ croissantModulesPath, ... }:
{
  _file = ./pigeonf.nix;

  imports = [
    (croissantModulesPath + "/profiles/base.nix")
    (croissantModulesPath + "/profiles/developer.nix")
    (croissantModulesPath + "/profiles/shell.nix")
  ];
}
