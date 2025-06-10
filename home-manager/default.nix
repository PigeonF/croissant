{ croissant-lib, ... }:
{
  _file = ./default.nix;

  imports = [
    ./flake-module.nix
  ];

  flake = {
    homeModules =
      let
        modules = {
          programs = _: {
            imports = [
              ./programs/_1password.nix
              ./programs/atuin.nix
              ./programs/bash.nix
              ./programs/bat.nix
              ./programs/btop.nix
              ./programs/cargo.nix
              ./programs/eza.nix
              ./programs/fd.nix
              ./programs/ghq.nix
              ./programs/git.nix
              ./programs/helix.nix
              ./programs/home-manager.nix
              ./programs/jujutsu.nix
              ./programs/nix.nix
              ./programs/nushell.nix
              ./programs/ripgrep.nix
              ./programs/starship.nix
              ./programs/vscodium.nix
              ./programs/yazi.nix
              ./programs/zellij.nix
              ./programs/zoxide.nix
              ./programs/zsh.nix
            ];
          };
          dotfiles = ./modules/dotfiles.nix;
          rust = ./modules/rust.nix;
        };
      in
      modules
      // {
        default = _: {
          imports = builtins.attrValues modules;
        };
      };
  };

  perSystem =
    { pkgs, ... }:
    {
      devShells = {
        home-manager = pkgs.mkShellNoCC {
          name = "home-manager";
          packages = [
            pkgs.home-manager
            pkgs.nh
          ];
        };
      };

      # Generic home configurations that are not specific to any OS configuration.
      homeConfigurations = {
        pigeonf = croissant-lib.mkHomeManagerConfiguration {
          inherit pkgs;

          modules = [ ./configurations/pigeonf.nix ];
        };
        root = croissant-lib.mkHomeManagerConfiguration {
          inherit pkgs;

          modules = [ ./configurations/root.nix ];
        };
      };
    };
}
