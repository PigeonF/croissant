# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Requires [just](https://just.systems).

set windows-shell := ["pwsh", "-C"]

HOSTKEY := "ssh_host_ed25519_key"

# Recipe that is executed when no recipe is given on the commandline.
_default:
    @{{ quote(just_executable()) }} --justfile {{ quote(source_file()) }} --list

# Install the dotfiles using [dotter](https://github.com/SuperCuber/dotter).
dotfiles *ARGS:
    dotter -v {{ ARGS }}

# Deploy the deploy-rs `target`
deploy target *ARGS:
    deploy {{ quote(".#" + target) }} {{ ARGS }}

# Deploy the `vm` to the `host`
deploy-vm host vm:
    nix run {{ quote(".#nixosConfigurations." + vm + ".config.microvm.deploy.installOnHost") }} {{ quote(host) }}
    ssh {{ quote(host) }} systemctl restart {{ quote("microvm@" + vm) }}

_generate-ssh-key file:
    mkdir -p {{ quote(parent_directory(file)) }}
    ssh-keygen -t ed25519 -N "" -C "" -f {{ quote(file) }}

_update-ssh-key name file:
    key=$(ssh-to-age -i {{ quote(file) }}) yq -i {{ quote('(._keys[] | select(anchor == "' + name + '")) = strenv(key)') }} .sops.yaml

# Generate a ssh host key for use during provisioning `host`.
generate-ssh-host-key host:
    @just --justfile {{ quote(source_file()) }} _generate-ssh-key {{ quote(".provisioning" / host / "persist" / "etc" / "ssh" / HOSTKEY) }}
# Update a ssh host public key in .sops.yaml for `host`.
update-ssh-host-key host:
    @just --justfile {{ quote(source_file()) }} _update-ssh-key {{ quote(host) }} {{ quote(".provisioning" / host / "persist" / "etc" / "ssh" / (HOSTKEY + ".pub")) }}

# Prepare a ssh host key for `host`.
prepare-ssh-host-key host:
    just --justfile {{ quote(source_file()) }} generate-ssh-host-key {{ quote(host) }}
    just --justfile {{ quote(source_file()) }} update-ssh-host-key {{ quote(host) }}

# Generate a ssh host key for the `host` initrd.
generate-initrd-ssh-host-key host:
    @just --justfile {{ quote(source_file()) }} _generate-ssh-key {{ quote (".provisioning" / host / "persist" / "secrets" / "boot" / "etc" / "ssh" / HOSTKEY) }}

# Generate a ssh host key for the `microvm` on the `host`
generate-microvm-ssh-host-key host microvm:
    @just --justfile {{ quote(source_file()) }} _generate-ssh-key {{ quote(".provisioning" / host / "persist" / "microvms" / microvm / "etc" / "ssh" / HOSTKEY) }}
# Update a ssh host key in .sops.yaml for the `microvm` on the `host`
update-microvm-ssh-host-key host microvm:
    @just --justfile {{ quote(source_file()) }} _update-ssh-key {{ quote(host + "-" + microvm) }} {{ quote(".provisioning" / host / "persist" / "microvms" / microvm / "etc" / "ssh" / (HOSTKEY + ".pub")) }}
# Prepare a ssh host key for the `microvm` on the `host`.
prepare-microvm-ssh-host-key host microvm:
    just --justfile {{ quote(source_file()) }} generate-microvm-ssh-host-key {{ quote(host) }} {{ quote(microvm) }}
    just --justfile {{ quote(source_file()) }} update-microvm-ssh-host-key {{ quote(host) }} {{ quote(microvm) }}

# Update the encrypted secrets in the repository.
update-secrets:
    find . -name "secrets.yaml" -print0 | xargs -0 sops updatekeys --yes
