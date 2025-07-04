{
  inputs,
  self,
  croissant-lib,
  ...
}:
let
  system = "x86_64-linux";
  deploySystem = "x86_64-linux";
  deployLib = inputs.deploy-rs.lib.${deploySystem};
in
{
  _file = ./default.nix;

  deploy-rs.nodes.ganymede = {
    hostname = "ganymede";
    profilesOrder = [
      "system"
      "root"
      "pigeonf"
    ];

    profiles = {
      system = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.nixos self.nixosConfigurations.ganymede;
      };
      root = {
        user = "root";
        sshUser = "root";
        path = deployLib.activate.home-manager inputs.self.legacyPackages.${system}.homeConfigurations.root;
      };
      pigeonf = {
        user = "pigeonf";
        sshUser = "pigeonf";
        path =
          deployLib.activate.home-manager
            inputs.self.legacyPackages.${system}.homeConfigurations.pigeonf;
      };
    };
  };

  flake = {
    nixosConfigurations = {
      ganymede = croissant-lib.mkNixOsConfiguration {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          inputs.home-manager.nixosModules.home-manager
          inputs.impermanence.nixosModules.impermanence
          inputs.lix-modules.nixosModules.default
          inputs.nixos-facter-modules.nixosModules.facter
          inputs.sops-nix.nixosModules.sops
          ./disks.nix
          ./graphics.nix
          ./networking.nix
          ./nix.nix
          ./system.nix
          ./users.nix
          ./virtualization.nix
          ./xdg.nix
        ];
      };
    };
  };

  perSystem = {
    packages = {
      ganymede = self.nixosConfigurations.ganymede.config.system.build.toplevel;
    };
  };
}
