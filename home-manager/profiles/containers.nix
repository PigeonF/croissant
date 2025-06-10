{
  pkgs,
  ...
}:
{
  _file = ./containers.nix;

  config = {
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          crane
          diffoci
          diffoscopeMinimal
          dive
          ;
      };
    };
  };
}
