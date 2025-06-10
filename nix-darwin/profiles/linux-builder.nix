# nix-darwin setup that has the linux builder enabled for aarch64-linux builds.
_: {
  _file = ./linux-builder.nix;

  imports = [
    ../nix/linux-builder.nix
    ../nix/nix.nix
    ../system/base.nix
  ];

  config = {
    croissant = {
      nix = {
        linux-builder.enable = true;
      };
    };

    system = {
      primaryUser = "pigeonf";
    };

    users = {
      users = {
        pigeonf = {
          openssh.authorizedKeys.keyFiles = [
            (../../dotfiles/ssh/.ssh/keys.d + "/pigeonf@github.com.pub")
          ];
        };
      };
    };
  };
}
