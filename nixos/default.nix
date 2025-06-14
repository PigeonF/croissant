_: {
  _file = ./default.nix;

  flake = {
    nixosModules =
      let
        modules = {
          base = ./modules/base.nix;
          lima = ./modules/lima.nix;
          nix = ./modules/nix.nix;
          ssh = ./modules/ssh.nix;
        };
      in
      modules
      // {
        default = _: {
          imports = builtins.attrValues modules;
        };
      };
  };
}
