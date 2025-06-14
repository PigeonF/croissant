{
  self,
  deploy-rs-lib,
  croissant-lib,
  ...
}:
let
  hostPlatform = "aarch64-darwin";
in
{
  _file = ./default.nix;

  flake = {
    darwinConfigurations = {
      jupiter = croissant-lib.mkDarwinSystem {
        modules = [
          ./jupiter.nix
          {
            nixpkgs = {
              inherit hostPlatform;
              overlays = [ self.overlays.default ];
            };
          }
        ];
      };
    };
  };

  perSystem =
    { pkgs, ... }:
    let
      pigeonf = croissant-lib.mkHomeManagerConfiguration {
        inherit pkgs;

        modules = [ ./pigeonf.nix ];
      };
      root = croissant-lib.mkHomeManagerConfiguration {
        inherit pkgs;

        modules = [ ./root.nix ];
      };
    in
    {
      homeConfigurations = {
        "jupiter.pigeonf" = pigeonf;
        "jupiter.root" = root;
      };

      packages = {
        jupiter = self.darwinConfigurations.jupiter.config.system.build.toplevel;
      };
    };

  deploy-rs.nodes.jupiter = {
    hostname = "192.168.7.2";
    profilesOrder = [
      "system"
      "root"
      "pigeonf"
    ];
    profiles =
      let
        deploy-lib = deploy-rs-lib.${hostPlatform};
      in
      {
        system = {
          sshUser = "root";
          path = deploy-lib.activate.darwin self.darwinConfigurations.jupiter;
        };
        root = {
          sshUser = "root";
          path =
            deploy-lib.activate.home-manager
              self.legacyPackages.${hostPlatform}.homeConfigurations."jupiter.root";
        };
        pigeonf = {
          sshUser = "pigeonf";
          path =
            deploy-lib.activate.home-manager
              self.legacyPackages.${hostPlatform}.homeConfigurations."jupiter.pigeonf";
        };
      };
  };
}
