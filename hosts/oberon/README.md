<!--
SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Oberon

[NixOS] configuration for a VM running on [phoebe](../phoebe/)..

[NixOS]: https://nixos.org/

## Update

Update the configuration locally by running `nixos-rebuild switch --flake .#oberon`.
To update the configuration remotely, use [deploy-rs].

```console
nixos-rebuild switch --flake .#oberon
# or
just hosts::oberon::update
```

[deploy-rs]: https://github.com/serokell/deploy-rs

## Installation

Install the configuration using [nixos-anywhere].
Use the provided [Justfile](./Justfile) to generate SSH host keys.

```console
just hosts::oberon::install root@192.168.178.123
just hosts::oberon::update
```

[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere
