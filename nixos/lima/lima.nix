{
  pkgs,
  ...
}:
{
  _file = ./lima.nix;

  config = {
    nix = {
      channel = {
        enable = false;
      };
      package = pkgs.nix;
      settings = {
        auto-allocate-uids = true;
        extra-experimental-features = [
          "flakes"
          "nix-command"
          "no-url-literals"
          "auto-allocate-uids"
          "cgroups"
        ];
        sandbox = true;
        system-features = [ "uid-range" ];
        trusted-users = [ "@wheel" ];
        use-cgroups = true;
        use-xdg-base-directories = true;
      };
    };
  };
}
