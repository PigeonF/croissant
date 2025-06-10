{ croissantModulesPath, inputs, ... }:
{
  _file = ./root.nix;

  imports = [
    inputs.self.homeModules.default
    (croissantModulesPath + "/profiles/users/root.nix")
  ];

  config = {
    croissant = {
      programs = {
        zsh.enable = true;
      };
    };

    home =
      let
        username = "root";
      in
      {
        stateVersion = "25.05";
        inherit username;
        homeDirectory = "/var/${username}";
      };
  };
}
