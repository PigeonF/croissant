# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Requires [just](https://just.systems).

set unstable
set windows-shell := ["pwsh", "-C"]

CALL := if os_family() == "windows"  { "& " } else { "" }

[doc('Recipes for interacting with the various hosts defined in this repository.')]
mod hosts

# Recipe that is executed when no recipe is given on the commandline.
[private]
list:
    @{{ CALL }}{{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} --list --list-submodules

# Install the dotfiles using [dotter](https://github.com/SuperCuber/dotter).
[group('deploy')]
dotfiles *ARGS:
    dotter -v {{ ARGS }}

foo:
    echo {{ which("lstopo.exe") }}
