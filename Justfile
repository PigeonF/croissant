# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Requires [just](https://just.systems).

set windows-shell := ["pwsh", "-C"]

HOSTKEY := "ssh_host_ed25519_key"

# Recipe that is executed when no recipe is given on the commandline.
[private]
list:
    @{{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} --list

# Install the dotfiles using [dotter](https://github.com/SuperCuber/dotter).
[group('deploy')]
dotfiles *ARGS:
    dotter -v {{ ARGS }}

# Deploy the deploy-rs `target`
[group('deploy')]
deploy target *ARGS:
    deploy {{ quote(".#" + target) }} {{ ARGS }}

# Deploy the `microvm` to the `host`
[group('deploy')]
deploy-vm host microvm:
    nix run {{ quote(".#nixosConfigurations." + microvm + ".config.microvm.deploy.rebuild") }} {{ quote(host) }} {{ quote(microvm) }}

# Prepare a ssh host key for the `microvm` on the `host`.
[group('deploy')]
prepare-microvm-ssh-host-key host microvm:
    just --justfile {{ quote(source_file()) }} generate-microvm-ssh-host-key {{ quote(host) }} {{ quote(microvm) }}
    just --justfile {{ quote(source_file()) }} update-microvm-ssh-host-key {{ quote(host) }} {{ quote(microvm) }}

# Prepare a ssh host key for `host`.
[group('deploy')]
prepare-ssh-host-key host:
    just --justfile {{ quote(source_file()) }} generate-ssh-host-key {{ quote(host) }}
    just --justfile {{ quote(source_file()) }} update-ssh-host-key {{ quote(host) }}

# Generate a ssh host key for the `host` initrd.
[group('generate')]
generate-initrd-ssh-host-key host:
    @just --justfile {{ quote(source_file()) }} generate-ssh-key {{ quote (".provisioning" / host / "persist" / "secrets" / "boot" / "etc" / "ssh" / HOSTKEY) }}

# Generate a ssh host key for the `microvm` on the `host`
[group('generate')]
generate-microvm-ssh-host-key host microvm:
    @just --justfile {{ quote(source_file()) }} generate-ssh-key {{ quote(".provisioning" / host / "persist" / "microvms" / microvm / "etc" / "ssh" / HOSTKEY) }}

# Generate a ssh host key for use during provisioning `host`.
[group('generate')]
generate-ssh-host-key host:
    @just --justfile {{ quote(source_file()) }} generate-ssh-key {{ quote(".provisioning" / host / "persist" / "etc" / "ssh" / HOSTKEY) }}

[group('generate')]
[private]
generate-ssh-key file:
    mkdir -p {{ quote(parent_directory(file)) }}
    ssh-keygen -t ed25519 -N "" -C "" -f {{ quote(file) }}

[group('test')]
test:
    nix flake check
    {{ if os() == "linux" { "nix build '.#serenno'" } else { "" } }}
    {{ if os() == "linux" { "nix build '.#raxus'" } else { "" } }}
    {{ if os() == "macos" { "nix build '.#kamino'" } else { "" } }}

# Update a ssh host key in .sops.yaml for the `microvm` on the `host`
[group('update')]
update-microvm-ssh-host-key host microvm:
    @just --justfile {{ quote(source_file()) }} update-ssh-key {{ quote(host + "-" + microvm) }} {{ quote(".provisioning" / host / "persist" / "microvms" / microvm / "etc" / "ssh" / (HOSTKEY + ".pub")) }}

# Update the encrypted secrets in the repository.
[group('update')]
update-secrets:
    find . -name "secrets.yaml" -print0 | xargs -0 sops updatekeys --yes

[group('update')]
[private]
update-ssh-key name file:
    key=$(ssh-to-age -i {{ quote(file) }}) yq -i {{ quote('(._keys[] | select(anchor == "' + name + '")) = strenv(key)') }} .sops.yaml

# Update a ssh host public key in .sops.yaml for `host`.
[group('update')]
update-ssh-host-key host:
    @just --justfile {{ quote(source_file()) }} update-ssh-key {{ quote(host) }} {{ quote(".provisioning" / host / "persist" / "etc" / "ssh" / (HOSTKEY + ".pub")) }}
