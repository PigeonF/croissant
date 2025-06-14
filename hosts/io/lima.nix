{
  croissantModulesPath,
  inputs,
  ...
}:
{
  _file = ./lima.nix;

  imports = [
    inputs.self.homeModules.default
    (croissantModulesPath + "/profiles/users/root.nix")
  ];

  config = {
    croissant = {
      programs = {
        bash.enable = true;
      };
    };

    home = {
      stateVersion = "25.05";
      username = "lima";
      homeDirectory = "/home/lima.linux";
    };
  };
}
