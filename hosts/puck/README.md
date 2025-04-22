<!--
SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Puck

[NixOS] configuration for a VM running on [phoebe](../phoebe/)..

[NixOS]: https://nixos.org/

## Update

Update the configuration locally by running `nixos-rebuild switch --flake .#puck`.
To update the configuration remotely, use [deploy-rs].

```console
nixos-rebuild switch --flake .#puck
# or
just hosts::puck::update
```

[deploy-rs]: https://github.com/serokell/deploy-rs

## Installation

Install the configuration using [nixos-anywhere].
Use the provided [Justfile](./Justfile) to generate SSH host keys.

```console
just hosts::puck::install root@192.168.178.123
just hosts::puck::update
```

[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere
