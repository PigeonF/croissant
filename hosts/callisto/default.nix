{
  inputs,
  croissant-lib,
  ...
}:
let
  system = "aarch64-darwin";
  deploySystem = "aarch64-darwin";
  deployLib = inputs.deploy-rs.lib.${deploySystem};

  callisto = croissant-lib.mkDarwinConfiguration {
    inherit system;
    specialArgs = {
      inherit inputs;
    };
    modules = [
      inputs.lix-modules.nixosModules.default
      ./homebrew.nix
      ./nix.nix
      ./system.nix
      ./users.nix
      ./xdg.nix
    ];
  };

  callisto-bootstrap = croissant-lib.mkDarwinConfiguration {
    inherit system;
    specialArgs = {
      inherit inputs;
    };
    modules = [
      inputs.lix-modules.nixosModules.default
      ./system.nix
      (_: {
        config = {
          launchd = {
            daemons = {
              linux-builder = {
                serviceConfig = {
                  StandardOutPath = "/var/log/darwin-builder.log";
                  StandardErrorPath = "/var/log/darwin-builder.log";
                };
              };
            };
          };
          nix = {
            linux-builder = {
              enable = true;
            };
            settings = {
              extra-experimental-features = [
                "flakes"
                "nix-command"
              ];
              trusted-users = [
                "@admin"
              ];
            };
          };
        };
      })
    ];
  };
in
{
  _file = ./default.nix;

  deploy-rs.nodes.callisto = {
    hostname = "callisto";
    profilesOrder = [
      "system"
      "root"
      "pigeonf"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "pigeonf";
        path = deployLib.activate.darwin callisto;
      };
      root = {
        user = "root";
        sudo = "sudo --login -u";
        sshUser = "pigeonf";
        interactiveSudo = true;
        path = deployLib.activate.home-manager inputs.self.legacyPackages.${system}.homeConfigurations.root;
      };
      pigeonf = {
        user = "pigeonf";
        sshUser = "pigeonf";
        interactiveSudo = true;
        path =
          deployLib.activate.home-manager
            inputs.self.legacyPackages.${system}.homeConfigurations.pigeonf;
      };
    };
  };

  flake = {
    darwinConfigurations = {
      inherit callisto callisto-bootstrap;
    };
  };

  perSystem = {
    packages = {
      callisto = callisto.config.system.build.toplevel;
      callisto-bootstrap = callisto-bootstrap.config.system.build.toplevel;
    };
  };
}
