<!--
SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Phoebe

[Nix-Darwin] configuration for a [Mac Mini M4 Pro].
The Mac Mini is used as a development environment for programming, as well as a server that hosts multiple VMs.

[Nix-Darwin]: https://github.com/nix-darwin/nix-darwin/
[Mac Mini M4 Pro]: https://support.apple.com/en-us/121555

## Hardware

![System hardware determined by the `hwloc` package](images/topology.svg "Generated using `just hosts::phoebe::topology`")

## Update

Update the configuration locally by running `darwin-rebuild switch --flake .#phoebe`.
To update the configuration remotely, use [deploy-rs].

```console
darwin-rebuild switch --flake .#phoebe
# or
just hosts::phoebe::update
```

[deploy-rs]: https://github.com/serokell/deploy-rs

## Installation

This configuration does not support automatic installation.
On a fresh system,

1. Install nix (for example using the [lix installer](https://lix.systems/install/)).
2. Install the bootstrap configuration using `nix --extra-experimental-features "nix-command flakes" run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake github:PigeonF/croissant#phoebe`.
3. Install the full configuration using `just hosts::phoebe::update`.
