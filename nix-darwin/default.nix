{ self, croissant-lib, ... }:
{
  _file = ./default.nix;

  imports = [
    ./flake-module.nix
  ];

  flake = {
    darwinModules =
      let
        modules = {
          nix = _: {
            imports = [
              ./nix/linux-builder.nix
              ./nix/nix.nix
            ];
          };
          services = _: {
            imports = [
              ./services/gitlab-tart-executor.nix
            ];
          };
          system = _: {
            imports = [
              ./system/base.nix
              ./system/homebrew.nix
            ];
          };
        };
      in
      modules
      // {
        default = _: {
          imports = builtins.attrValues modules;
        };
      };

    darwinConfigurations = {
      linux-builder = croissant-lib.mkDarwinSystem {
        modules = [
          (
            { croissantModulesPath, ... }:
            {
              imports = [
                (croissantModulesPath + "/profiles/linux-builder.nix")
              ];

              nixpkgs = {
                hostPlatform = "aarch64-darwin";
              };

              system = {
                configurationRevision = self.rev or self.dirtyRev or null;
                stateVersion = 6;
              };
            }
          )
        ];
      };
    };

    flakeModules = {
      nix-darwin = ./flake-module.nix;
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packages = {
        linux-builder-test = pkgs.runCommand "linux-builder-test" { } ''
          uname -a > $out
        '';
      };
    };
}
