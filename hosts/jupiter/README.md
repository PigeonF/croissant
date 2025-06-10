# Jupiter

[Nix-Darwin][] configuration for a [Mac Mini M4 Pro][].
The Mac Mini is used as a development environment for programming, as well as a server that hosts multiple VMs.

[Nix-Darwin]: https://github.com/nix-darwin/nix-darwin/
[Mac Mini M4 Pro]: https://support.apple.com/en-us/121555

## Update

Update the configuration locally by running `darwin-rebuild switch --flake .#jupiter`.
To update the configuration remotely, use [deploy-rs][].

```console
darwin-rebuild switch --flake .#phoebe
# or
just jupiter::update
```

[deploy-rs]: https://github.com/serokell/deploy-rs

## Installation

This configuration does not support automatic installation.
On a fresh system

1. Install [`just`][].
2. Run `just jupiter::setup`.

[`just`]: https://just.systems/
