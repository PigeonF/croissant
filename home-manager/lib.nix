{ inputs, home-manager-lib, ... }:
{
  mkHomeManagerConfiguration =
    args@{
      extraSpecialArgs ? { },
      croissantModulesPath ? ./.,
      ...
    }:
    home-manager-lib.homeManagerConfiguration (
      {
        extraSpecialArgs = {
          inherit croissantModulesPath inputs;
        } // extraSpecialArgs;
      }
      // builtins.removeAttrs args [
        "extraSpecialArgs"
      ]
    );
}
