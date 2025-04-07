# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Requires [just](https://just.systems).

[group('maintenance')]
[doc('Output the hardware topology to the DESTINATION.')]
topology DESTINATION=("images" / "topology.svg"):
    @mkdir -p {{ quote(parent_directory(clean(DESTINATION))) }}
    @rm -f {{ quote(clean(DESTINATION)) }}
    nix shell "nixpkgs#hwloc" --command lstopo {{ quote(clean(DESTINATION)) }}
