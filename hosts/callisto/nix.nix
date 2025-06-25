{
  inputs,
  pkgs,
  ...
}:
{
  _file = ./nix.nix;

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
      channel = {
        enable = false;
      };
      linux-builder = {
        enable = true;
        ephemeral = true;
        maxJobs = 4;

        config = {
          virtualisation = {
            darwin-builder = {
              diskSize = 4 * 20 * 1024;
              memorySize = 4 * 1024;
            };
            cores = 4;
          };
        };
      };
      package = pkgs.nixVersions.stable;
      registry = {
        nixpkgs-stable = {
          exact = true;
          from = {
            type = "indirect";
            id = "nixpkgs-stable";
          };
          to = {
            type = "path";
            path = inputs.nixpkgs-stable;
          };
        };
      };
      settings = {
        extra-experimental-features = [
          "flakes"
          "nix-command"
          "no-url-literals"
        ];
        sandbox = true;
        trusted-users = [
          "@admin"
          "@wheel"
        ];
        use-xdg-base-directories = true;
      };
    };
  };
}
