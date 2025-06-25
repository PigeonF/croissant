{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  settings = {
    excludes = [
      ".dotter/cache/*"
      ".jj/*"
      "*.gitignored.*"
      "LICENSES/*"
    ];
    on-unmatched = "debug";
  };

  programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    prettier.enable = true;
    statix.enable = true;
  };

  settings.formatter = {
    editorconfig-checker = {
      command = pkgs.editorconfig-checker;
      includes = [ "*" ];
      # Run last
      priority = 99;
    };

    prettier = {
      excludes = [ "*secrets.yaml" ];
    };
  };
}
