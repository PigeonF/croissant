_: {
  _file = ./users.nix;

  config = {
    users = {
      users = {
        pigeonf = {
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgBXuwsvHPBuk9OMHraUbEObvyJn8wHw6XKX/1KWAiX"
              ];
            };
          };
        };
        root = {
          shell = "/bin/zsh";
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIML5ZEA0tlfUTUw0kNol2/iU8RqfIvS0h3A4K17kwcmU"
              ];
            };
          };
        };
      };
    };
  };
}
