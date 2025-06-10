{
  croissantModulesPath,
  inputs,
  pkgs,
  ...
}:
{
  _file = ./pigeonf.nix;

  imports = [
    inputs.self.homeModules.default
    (croissantModulesPath + "/profiles/users/pigeonf.nix")
  ];

  config = {
    home =
      let
        username = "pigeonf";
      in
      {
        stateVersion = "25.05";
        inherit username;
        homeDirectory =
          if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";
      };
  };
}
