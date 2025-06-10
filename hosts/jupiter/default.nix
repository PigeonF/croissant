{
  croissant-lib,
  deploy-rs-lib,
  home-manager-lib,
  inputs,
  self,
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
            };
          }
        ];
      };
    };
  };

  perSystem =
    { pkgs, system, ... }:
    let
      pigeonf = home-manager-lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs system;
        };

        modules = [ ./pigeonf.nix ];
      };
      root = home-manager-lib.homeManagerConfiguration {
        inherit pkgs;

        extraSpecialArgs = {
          inherit inputs system;
        };

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
