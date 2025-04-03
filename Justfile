# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Requires [just](https://just.systems).

[doc('Recipes for interacting with the various hosts defined in this repository.')]
mod hosts

set windows-shell := ["pwsh", "-C"]

# Recipe that is executed when no recipe is given on the commandline.
[private]
list:
    @{{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} --list --list-submodules

# Install the dotfiles using [dotter](https://github.com/SuperCuber/dotter).
[group('deploy')]
dotfiles *ARGS:
    dotter -v {{ ARGS }}
