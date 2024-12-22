# SPDX-FileCopyrightText: 2024 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Requires [just](https://just.systems).

set windows-shell := ["pwsh", "-C"]

# Recipe that is executed when no recipe is given on the commandline.
_default:
    @{{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} --list

# Install the dotfiles using [dotter](https://github.com/SuperCuber/dotter).
dotfiles *ARGS:
    dotter -v {{ ARGS }}
