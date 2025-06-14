{ inputs, ... }:
{
  _file = ./default.nix;

  flake = {
    overlays =
      let
        overlays = {
          unstablePackages = final: _: {
            unstablePackages = inputs.nixpkgs-unstable.legacyPackages.${final.system};
          };
          patchedPackages = final: _: {
            patchedPackages = {
              reuse = final.callPackage ./reuse { };
            };
          };
          upstreamPackages = _: _: {

          };
        };
      in
      overlays
      // {
        default = inputs.nixpkgs.lib.composeManyExtensions (builtins.attrValues overlays);
      };
  };
}
