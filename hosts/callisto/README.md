<!--
SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Callisto

[Nix-Darwin] configuration for a [MacBook Pro 2023 M2 Max].
The MacBook is used as a development environment for programming.

[Nix-Darwin]: https://github.com/nix-darwin/nix-darwin/
[MacBook Pro 2023 M2 Max]: https://support.apple.com/en-us/111838

## Hardware

![System hardware determined by the `hwloc` package](images/topology.svg "Generated using `just hosts::callisto::topology`")

## Update

Update the configuration locally by running `darwin-rebuild switch --flake .#callisto`.
To update the configuration remotely, use [deploy-rs].

```console
darwin-rebuild switch --flake .#callisto
# or
just hosts::callisto::update
```

[deploy-rs]: https://github.com/serokell/deploy-rs

## Installation

This configuration does not support automatic installation.
On a fresh system,

1. Install nix (for example using the [lix installer](https://lix.systems/install/)).
2. Install the bootstrap configuration using `nix --extra-experimental-features "nix-command flakes" run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake .#callisto-bootstrap`.
3. Install the full configuration using `just hosts::callisto::update`.

## Future Work

- **Extensive System Settings**: Use the [Nix-Darwin] settings to set [system defaults](https://mynixos.com/nix-darwin/options/system.defaults).
