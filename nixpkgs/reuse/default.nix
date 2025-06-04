# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ reuse, ... }:
reuse.overrideAttrs (
  _: previousAttrs: {
    patches = (previousAttrs.patches or [ ]) ++ [ ./jj.patch ];
  }
)
