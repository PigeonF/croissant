{
  self,
  deploy-rs-lib,
  croissant-lib,
  ...
}:
let
  hostPlatform = "aarch64-linux";
in
{
  _file = ./default.nix;

  flake = {
    nixosConfigurations = {
      io = croissant-lib.mkNixOsSystem {
        modules = [
          ./io.nix
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
      root = croissant-lib.mkHomeManagerConfiguration {
        inherit pkgs;

        modules = [ ./root.nix ];
      };
      lima = croissant-lib.mkHomeManagerConfiguration {
        inherit pkgs;

        modules = [ ./lima.nix ];
      };
    in
    {
      homeConfigurations = {
        "io.root" = root;
        "io.lima" = lima;
      };

      packages = {
        io = self.nixosConfigurations.io.config.system.build.toplevel;
        "io.image" = self.nixosConfigurations.io.config.formats.qcow-efi;
      };
    };

  deploy-rs.nodes.io = {
    hostname = "lima-io";
    sshOpts = [
      "-F"
      # TODO(PigeonF): Open issue at deploy-rs tracker about expanding ~/ ?
      "/Users/pigeonf/.lima/io/ssh.config"
    ];
    profilesOrder = [
      "system"
      "root"
      "lima"
    ];
    profiles =
      let
        deploy-lib = deploy-rs-lib.${hostPlatform};
      in
      {
        system = {
          sshUser = "lima";
          user = "root";
          path = deploy-lib.activate.nixos self.nixosConfigurations.io;
        };
        root = {
          sshUser = "lima";
          user = "root";
          path =
            deploy-lib.activate.home-manager
              self.legacyPackages.${hostPlatform}.homeConfigurations."io.root";
        };
        lima = {
          sshUser = "lima";
          path =
            deploy-lib.activate.home-manager
              self.legacyPackages.${hostPlatform}.homeConfigurations."io.lima";
        };
      };
  };
}
