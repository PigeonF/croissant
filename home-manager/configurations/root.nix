{
  croissantModulesPath,
  inputs,
  pkgs,
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

    home =
      let
        username = "root";
      in
      {
        stateVersion = "25.05";
        inherit username;
        homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/var/${username}" else "/${username}";
      };
  };
}
