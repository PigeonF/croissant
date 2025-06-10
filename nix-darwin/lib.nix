{ inputs, nix-darwin-lib, ... }:
{
  mkDarwinSystem =
    args@{
      specialArgs ? { },
      croissantModulesPath ? ./.,
      ...
    }:
    nix-darwin-lib.darwinSystem (
      {
        specialArgs = {
          inherit croissantModulesPath inputs;
        } // specialArgs;
      }
      // builtins.removeAttrs args [
        "specialArgs"
      ]
    );
}
