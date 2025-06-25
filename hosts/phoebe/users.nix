_: {
  _file = ./users.nix;

  config = {
    users = {
      users = {
        pigeonf = {
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHG7IZmTNen1tZ8SqgXTkzM95jvs+RpzxKoZnZmdvZM"
              ];
            };
          };
        };
        root = {
          shell = "/bin/zsh";
          openssh = {
            authorizedKeys = {
              keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII4oLyEWmqsPJR1o4mCkXsHo4E9epPPMFS8uJL8JHNB+"
              ];
            };
          };
        };
      };
    };
  };
}
