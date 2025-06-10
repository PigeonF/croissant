{ croissantModulesPath, inputs, ... }:
{
  _file = ./pigeonf.nix;

  imports = [
    inputs.self.homeModules.default
    (croissantModulesPath + "/profiles/containers.nix")
    (croissantModulesPath + "/profiles/sysadmin.nix")
    (croissantModulesPath + "/profiles/users/pigeonf.nix")
  ];

  config = {
    croissant = {
      dotfiles.enable = true;
      rust.enable = true;

      programs = {
        _1password.enable = true;
        nushell.enable = true;
        vscodium.enable = true;
        zsh.enable = true;
      };
    };

    home =
      let
        username = "pigeonf";
      in
      {
        stateVersion = "25.05";
        inherit username;
        homeDirectory = "/Users/${username}";
      };
  };
}
