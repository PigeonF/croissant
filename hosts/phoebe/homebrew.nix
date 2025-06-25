_: {
  _file = ./homebrew.nix;

  config = {
    environment = {
      systemPath = [ "/opt/homebrew/bin" ];
    };

    homebrew = {
      enable = true;
      casks = [
        "vmware-fusion"
      ];
    };
  };
}
