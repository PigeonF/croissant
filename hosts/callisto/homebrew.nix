_: {
  _file = ./homebrew.nix;

  config = {
    homebrew = {
      enable = true;
      casks = [
        "1password"
        "alacritty"
        "brave-browser"
        "docker"
        "firefox"
        "font-recursive-mono-nerd-font"
        "font-victor-mono-nerd-font"
        "utm"
      ];
    };
  };
}
