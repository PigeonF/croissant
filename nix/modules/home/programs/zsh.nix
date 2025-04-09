# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    ;
  cfg = config.croissant.programs.zsh;
in
{
  _file = ./zsh.nix;

  options.croissant.programs = {
    zsh = {
      enable = mkEnableOption "set up zsh";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      activation = {
        sourceZshFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -s "$HOME/.zshenv" ]; then
            run rm -f "$HOME/.zshenv"
            run echo 'source "$HOME"/${
              lib.escapeShellArg config.home.file.".zshenv".target
            }' > "$HOME/.zshenv"
          fi
        '';
      };

      file = {
        ".zshenv" = {
          target = ".config/zsh/zshenv";
        };
      };
    };

    programs = {
      zsh = {
        enable = true;
        dotDir = ".config/zsh";
        defaultKeymap = "emacs";
        history = {
          path = "${config.xdg.dataHome}/zsh/zsh_history";
        };
        initExtraBeforeCompInit = ''
          # https://wiki.archlinux.org/title/Zsh#Key_bindings
          typeset -g -A key

          key[Home]="''${terminfo[khome]}"
          key[End]="''${terminfo[kend]}"
          key[Insert]="''${terminfo[kich1]}"
          key[Backspace]="''${terminfo[kbs]}"
          key[Delete]="''${terminfo[kdch1]}"
          key[Up]="''${terminfo[kcuu1]}"
          key[Down]="''${terminfo[kcud1]}"
          key[Left]="''${terminfo[kcub1]}"
          key[Right]="''${terminfo[kcuf1]}"
          key[PageUp]="''${terminfo[kpp]}"
          key[PageDown]="''${terminfo[knp]}"
          key[Shift-Tab]="''${terminfo[kcbt]}"
          key[Ctrl-Left]="^[[1;5D"
          key[Ctrl-Right]="^[[1;5C"

          [[ -n "''${key[Home]}"      ]] && bindkey -- "''${key[Home]}"         beginning-of-line
          [[ -n "''${key[End]}"       ]] && bindkey -- "''${key[End]}"          end-of-line
          [[ -n "''${key[Insert]}"    ]] && bindkey -- "''${key[Insert]}"       overwrite-mode
          [[ -n "''${key[Backspace]}" ]] && bindkey -- "''${key[Backspace]}"    backward-delete-char
          [[ -n "''${key[Delete]}"    ]] && bindkey -- "''${key[Delete]}"       delete-char
          [[ -n "''${key[Up]}"        ]] && bindkey -- "''${key[Up]}"           up-line-or-history
          [[ -n "''${key[Down]}"      ]] && bindkey -- "''${key[Down]}"         down-line-or-history
          [[ -n "''${key[Left]}"      ]] && bindkey -- "''${key[Left]}"         backward-char
          [[ -n "''${key[Right]}"     ]] && bindkey -- "''${key[Right]}"        forward-char
          [[ -n "''${key[PageUp]}"    ]] && bindkey -- "''${key[PageUp]}"       beginning-of-buffer-or-history
          [[ -n "''${key[PageDown]}"  ]] && bindkey -- "''${key[PageDown]}"     end-of-buffer-or-history
          [[ -n "''${key[Shift-Tab]}" ]] && bindkey -- "''${key[Shift-Tab]}"    reverse-menu-complete
          [[ -n "''${key[Ctrl-Left]}" ]] && bindkey -- "''${key[Ctrl-Left]}"    backward-word
          [[ -n "''${key[Ctrl-Right]}" ]] && bindkey -- "''${key[Ctrl-Right]}"  forward-word
        '';
      };
    };
  };
}
