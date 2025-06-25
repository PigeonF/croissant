{ pkgs, ... }:
{
  _file = ./graphics.nix;

  config = {
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
      systemPackages = [
        pkgs.alacritty
        pkgs.fuzzel
        pkgs.ghostty
        pkgs.nautilus
        pkgs.swaylock
        pkgs.wl-clipboard
        pkgs.xsel
        pkgs.xwayland-satellite
      ];
    };
    fonts = {
      # TODO(PigeonF): Move to alacritty home manager module
      packages = [
        pkgs.nerd-fonts.recursive-mono
        pkgs.nerd-fonts.victor-mono
      ];
    };
    programs = {
      _1password = {
        enable = true;
      };
      _1password-gui = {
        enable = true;
        polkitPolicyOwners = [ "pigeonf" ];
      };
      firefox = {
        enable = true;
      };
      niri = {
        enable = true;
      };
    };
    services = {
      displayManager = {
        ly = {
          enable = true;
          settings = {
            # XXX(PigeonF): Wait for new ly version
            # brightness_down_cmd = "${lib.getExe pkgs.brightnessctl} -q s 10%-";
            # brightness_down_key = "F5";
            # brightness_up_cmd = "${lib.getExe pkgs.brightnessctl} -q s +10%";
            # brightness_up_key = "F6";
            clock = "%c";
          };
        };
      };
    };
    xdg = {
      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };
    };
  };
}
