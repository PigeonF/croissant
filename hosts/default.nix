_: {
  _file = ./default.nix;

  imports = [
    ./flake-module.nix
    ./io
    ./jupiter
  ];

  flake = {
    flakeModules = {
      deploy-rs = ./flake-module.nix;
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        hosts = pkgs.mkShellNoCC {
          name = "hosts";
          packages = [
            pkgs.age
            pkgs.just
            pkgs.mkpasswd
            pkgs.nixos-anywhere
            pkgs.openssh
            pkgs.pwgen
            pkgs.sops
            pkgs.ssh-to-age
            pkgs.yq-go
          ];
        };
      };
    };
}
