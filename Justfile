# Requires [just](https://just.systems).

set ignore-comments := true
set unstable := true
set windows-shell := ["busybox", "sh", "-eu", "-c"]

[doc("""
    Recipes for the home-manager setup.
""")]
mod home-manager "home-manager/Justfile"

[doc("""
    Recipes for the nix-darwin setup.
""")]
mod nix-darwin "nix-darwin/Justfile"

[doc("""
    Configuration for the mac mini.
""")]
mod jupiter "hosts/jupiter/Justfile"

[private]
default:
    @{{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} --list

[doc("""
    Run the tests
""")]
[group("test")]
test:
    {{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} home-manager::test
    {{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} nix-darwin::test
    {{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} jupiter::test

[doc("""
    Install the dotfiles using dotter.

    Requires

    -   [`dotter`](https://github.com/SuperCuber/dotter)
""")]
[group("deploy")]
dotfiles *ARGS:
    dotter -v {{ ARGS }}
