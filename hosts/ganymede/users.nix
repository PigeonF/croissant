{
  config,
  ...
}:
{
  _file = ./users.nix;

  config = {
    environment = {
      persistence = {
        "/persist" = {
          users =
            let
              commonDirectories = [
                {
                  directory = ".ssh";
                  mode = "0700";
                }
              ];
              xdgDirectories = [
                ".config"
                ".local/bin"
                ".local/share"
              ];
            in
            {
              pigeonf = {
                directories =
                  commonDirectories
                  ++ xdgDirectories
                  ++ [
                    "code"
                    "Desktop"
                    "Documents"
                    "Downloads"
                    "Music"
                    "Pictures"
                    "Videos"
                  ];
                files = [
                  ".bash_profile"
                  ".bashrc"
                  ".profile"
                  ".zshenv"
                ];
              };
              root = {
                home = "/root";
                directories = commonDirectories ++ xdgDirectories;
                files = [
                  ".bash_profile"
                  ".bashrc"
                  ".profile"
                  ".zshenv"
                ];
              };
            };
        };
        "/cache" = {
          users =
            let
              xdgDirectories = [
                ".cache"
                ".local/state"
              ];
            in
            {
              pigeonf = {
                directories = xdgDirectories ++ [
                  ".docker"
                  ".mozilla"
                  ".pki"
                  ".vscode-oss"
                  ".vscodium-server"
                ];
              };
              root = {
                home = "/root";
                directories = xdgDirectories;
              };
            };
        };
      };
    };

    sops = {
      secrets = {
        "root/password" = {
          neededForUsers = true;
        };
        "pigeonf/password" = {
          neededForUsers = true;
        };
      };
    };

    users = {
      mutableUsers = false;
      users = {
        pigeonf = {
          isNormalUser = true;
          hashedPasswordFile = config.sops.secrets."pigeonf/password".path;
          extraGroups = [
            "docker"
            "wheel"
          ];
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJfXIy5QQ2OyapsCr5OJsuDcV4tNUVwG2PtyKEh1W5e"
              ];
            };
          };
        };

        root = {
          hashedPasswordFile = config.sops.secrets."root/password".path;
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOZWVYrGZVFnvwpJLBWSD/y3HnTU++eJez5Ip2WvQeNe"
              ];
            };
          };
        };
      };
    };
  };
}
