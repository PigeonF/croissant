# Default setup for jupiter
{
  inputs,
  ...
}:
{
  _file = ./jupiter.nix;

  imports = [
    inputs.lix-modules.nixosModules.default
    inputs.nix-rosetta-builder.darwinModules.default
    inputs.self.darwinModules.default
    inputs.sops-nix.darwinModules.sops
  ];

  config = {
    croissant = {
      homebrew.enable = true;
      services = {
        gitlab-tart-executor = {
          enable = true;
        };
      };
    };

    homebrew = {
      brews = [ "lima" ];
    };

    nix-rosetta-builder = {
      enable = true;
      onDemand = true;
    };

    services = {
      gitlab-runner.enable = true;
    };

    system = {
      primaryUser = "pigeonf";
    };

    users = {
      users = {
        pigeonf = {
          openssh.authorizedKeys.keyFiles = [
            (../../dotfiles/ssh/.ssh/keys.d + "/pigeonf@jupiter.pub")
          ];
        };
        root = {
          openssh.authorizedKeys.keyFiles = [
            (../../dotfiles/ssh/.ssh/keys.d + "/root@jupiter.pub")
          ];
        };
      };
    };
  };
}
