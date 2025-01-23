<!--
SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>

SPDX-License-Identifier: CC-BY-4.0
-->

# Croissant

## Windows

Use the [installation](./scripts/Windows-Install.ps1), and [bootstrap](./scripts/Windows-Bootstrap.ps1) scripts from an elevated powershell.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Import-Module DISM
irm 'https://raw.githubusercontent.com/PigeonF/croissant/refs/heads/main/scripts/Windows-Install.ps1' | iex
Invoke-Bootstrap -Revision "refs/heads/main"
jj git clone git@github.com:PigeonF/croissant.git D:\code\croissant
cd D:\code\croissant
just dotfiles
```

## Serenno

Deploy the serenno host using [`nixos-anywhere`] on first install.
Afterwards, the configuration can be updated using [`deploy-rs`].

[`nixos-anywhere`]: https://github.com/nix-community/nixos-anywhere
[`deploy-rs`]: https://github.com/serokell/deploy-rs

### First Provisioning

_This is only required when provisioning the machine for the first time_.

Since secrets are encrypted using the machine's SSH host key, there is chicken-and-egg problem:
without provisioning the machine we don't know the SSH host key, and without the SSH host key we cannot encrypt the secrets for provisioning.
The solution is to generate the SSH host keys ourselves and copy them using [`nixos-anywhere`].

```console
just prepare-ssh-host-key serenno
just prepare-microvm-ssh-host-key serenno raxus
```

If the target uses the initrd to decrypt any encrypted disks, you also have to generate SSH host keys for the initrd.

```console
just generate-initrd-ssh-host-key serenno
```

Re-encrypt any secrets that need updating for the new host keys.

```console
just update-secrets
```

<details>
<summary>
Example incus VM setup for testing
</summary>

I currently test _serenno_ in an [incus](https://linuxcontainers.org/incus/) VM.
First, prepare a live installer ISO image (it does not matter which distribution).

```console
incus launch images:debian/bookworm serenno --vm -c limits.cpu=2 -c limits.memory=4GiB -d root,size=64GiB
incus exec serenno -- apt-get install -y curl ssh
incus exec serenno -- curl https://github.com/PigeonF.keys -o .ssh/authorized_keys
incus exec serenno -- chmod 0600 .ssh/authorized_keys
ssh-keygen -R serenno.incus
ssh root@serenno.incus "hostname"
```

</details>

Install the configuration using [`nixos-anywhere`].

```console
HOST=root@serenno.incus
nixos-anywhere --flake '.#serenno' --phases kexec --generate-hardware-config nixos-facter ./nix/configurations/nixos/serenno/facter.json --target-host "$HOST"
nixos-anywhere --flake '.#serenno' --phases disko,install,reboot --extra-files ".provisioning/serenno/" --target-host "$HOST"
ssh-keygen -R serenno.incus
rm -rf .provisioning/serenno
```

### Deploying Changes

Once the system has been provisioned, it can be updated using [`deploy-rs`].

```console
deploy '.#serenno'
```

To deploy changes to a microvm, use `deploy-vm`.

```console
just deploy-vm serenno.incus raxus
```

Since the microvms are generally not exposed outside of the microvm host, you have to configure a SSH jump host for the microvm address.

```ssh-config
Host raxus raxus.serenno.incus
  User root
  HostName raxus
  ProxyJump root@serenno.incus
```

## Kamino

Install nix using the [lix-installer](https://lix.systems/install/#on-any-other-linuxmacos-system).
Install the XCode tools using `sudo xcode-select --install`.

Set up passwordless sudo for `wheel`.

```console
$ visudo -f /etc/sudoers.d/wheel
%wheel  ALL=(ALL) NOPASSWD: ALL
```

You can deploy to kamino from another machine, but beware that you have to pass the `--skip-checks` flag if you deploy from a linux machine.

```console
deploy --skip-checks --remote-build '.#kamino'
```
