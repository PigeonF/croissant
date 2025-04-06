<!--
SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Ganymede

[NixOS] configuration for a [Lenovo Thinkpad T480s laptop].
The laptop is used as a development environment for programming.

[NixOS]: https://nixos.org/
[Lenovo Thinkpad T480s laptop]: https://download.lenovo.com/pccbbs/mobiles_pdf/t480s_ug_en.pdf

## Hardware

![System hardware determined by the `hwloc` package](images/topology.svg "Generated using `lstopo topology.svg`")

## Services

| Protocol | Port | Service | Product          |
| -------- | ---- | ------- | ---------------- |
| TCP      | 22   | ssh     | OpenSSH          |
| TCP      | 5355 | llmnr   | systemd-resolved |

## Update

Update the configuration locally by running `nixos-rebuild switch --flake .#ganymede`.
To update the configuration remotely, use [deploy-rs].

```console
nixos-rebuild switch --flake .#ganymede
# or
just hosts::ganymede::update
```

[deploy-rs]: https://github.com/serokell/deploy-rs

## Installation

Install the configuration using [nixos-anywhere].
Use the provided [Justfile](./Justfile) to generate SSH host keys and a disk encryption password.
After installation, it is recommended to add a LUKS key slot utilizing the TPM2 module for easier hard disk unlocking.

```console
just hosts::ganymede::install root@192.168.178.123
```

```console
root@ganymede # systemd-cryptenroll /dev/nvme0n1p2 --tpm2-device=auto --wipe-slot=tpm2 --tpm2-pcrs=0+7+15:sha256=0000000000000000000000000000000000000000000000000000000000000000 --tpm2-with-pin=yes
```

[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere

## Future Work

- **Secure Boot**: Once [lanzaboote] is either upstreamed into nixpkgs, or the support for remote signing is merged it might be interesting to enable secure boot on the laptop.
- **Remote Unlock**: The hard disk should be unlockable remotely. In theory this should work (the initrd has a SSH server enabled), but in practice connection attempts time out (some issue with the networking setup in the initrd?)

[lanzaboote]: https://github.com/nix-community/lanzaboote
