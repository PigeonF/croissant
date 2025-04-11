# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ nixpkgs, ... }:

let
  inherit (nixpkgs) lib;

  overlays = {
    gitlab-runner = _: prev: {
      # https://gitlab.com/gitlab-org/gitlab-runner/-/issues/38262
      gitlab-runner = prev.gitlab-runner.overrideAttrs (
        _: previousAttrs: {
          ldflags = previousAttrs.ldflags ++ [
            "-B gobuildid"
            "-buildid 9037CDCD-5315-31E5-FF83-EDD32673FD6E"
          ];
        }
      );
    };
    release-plz = final: prev: {
      release-plz = prev.release-plz.overrideAttrs (
        _: previousAttrs: {
          buildInputs = previousAttrs.buildInputs ++ [ final.curl.dev ];
        }
      );
    };
  };
in

overlays // { default = lib.composeManyExtensions (builtins.attrValues overlays); }
