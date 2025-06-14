{ inputs, nixpkgs-lib, ... }:
{
  mkNixOsSystem =
    args@{
      specialArgs ? { },
      croissantModulesPath ? ./.,
      croissantHomeManagerModulesPath ? ../home-manager,
      ...
    }:
    nixpkgs-lib.nixosSystem (
      {
        specialArgs = {
          inherit croissantModulesPath croissantHomeManagerModulesPath inputs;
        } // specialArgs;
      }
      // builtins.removeAttrs args [
        "specialArgs"
      ]
    );
}
