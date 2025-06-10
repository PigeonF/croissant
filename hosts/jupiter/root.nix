{ inputs, ... }:
{
  _file = ./root.nix;

  imports = [
    inputs.self.homeManagerModules.root
    inputs.self.homeManagerModules.programs.zsh
  ];

  config = {
    croissant = {
      programs = {
        zsh.configure = true;
      };
    };

    home = {
      stateVersion = "25.05";
      username = "root";
      homeDirectory = "/var/root";
    };
  };
}
