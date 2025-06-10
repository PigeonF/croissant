# Base configuration that should be part of every nix-darwin configuration
{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.croissant.nix;
in
{
  _file = ./base.nix;

  options = {
    croissant.nix = {
      enable = mkEnableOption "the nix configuration" // {
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {
    nix = {
      channel = {
        enable = false;
      };
      nixPath = [ "nixpkgs-unstable=flake:nixpkgs-unstable" ];
      registry = {
        nixpkgs-unstable = {
          to = {
            type = "path";
            path = inputs.nixpkgs-unstable;
          };
        };
      };
      settings = {
        extra-experimental-features = [
          "flakes"
          "nix-command"
          "no-url-literals"
        ];
        sandbox = "relaxed"; # true; # https://github.com/NixOS/nix/issues/12698
        trusted-users = [
          "@admin"
          "@wheel"
        ];
        use-xdg-base-directories = true;
      };
    };
  };
}
