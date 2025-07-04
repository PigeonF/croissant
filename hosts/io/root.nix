{
  croissantModulesPath,
  inputs,
  ...
}:
{
  _file = ./root.nix;

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
      username = "root";
      homeDirectory = "/root";
    };
  };
}
