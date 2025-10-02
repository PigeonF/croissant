{ inputs, lib, ... }:
{
  _file = ./default.nix;

  flake = {
    overlays =
      let
        overlays = {
          unstablePackages = final: _: {
            unstablePackages = inputs.nixpkgs-unstable.legacyPackages.${final.system};
          };
          masterPackages = final: _: {
            masterPackages = inputs.nixpkgs-master.legacyPackages.${final.system};
          };
          patchedPackages = final: _: {
            patchedPackages = {
              reuse = final.callPackage ./reuse { };
            };
          };
          upstreamPackages = _: _: {

          };
          qemuStatic = final: previous: {
            nettle = previous.nettle.overrideAttrs (
              lib.optionalAttrs final.stdenv.hostPlatform.isStatic {
                CCPIC = "-fPIC";
              }
            );
          };
        };
      in
      overlays
      // {
        default = inputs.nixpkgs.lib.composeManyExtensions (builtins.attrValues overlays);
      };
  };
}
