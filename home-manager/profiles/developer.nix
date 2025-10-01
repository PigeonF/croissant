{
  pkgs,
  ...
}:
{
  _file = ./developer.nix;

  config = {
    croissant = {
      programs = {
        ghq.enable = true;
        git.enable = true;
        helix.enable = true;
        jujutsu.enable = true;
        zellij.enable = true;
      };
    };
    home = {
      packages = builtins.attrValues {
        inherit (pkgs)
          age
          curl
          gh
          jq
          sd
          sops
          ssh-to-age
          yq
          ;
        inherit (pkgs.patchedPackages) reuse;
        inherit (pkgs.unstablePackages) glab just;
      };
    };
  };
}
