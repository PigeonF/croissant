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

# Generate a ssh host key for use during provisioning `host`.
generate-ssh-host-key host:
    mkdir -p {{ quote(".provisioning" / host / "persist" / "etc" / "ssh") }}
    ssh-keygen -t ed25519 -N "" -C "" -f {{ quote(".provisioning" / host / "persist" / "etc" / "ssh" / HOSTKEY) }}

# Generate a ssh host key for the `host` initrd.
generate-initrd-ssh-host-key host:
    mkdir -p {{ quote(".provisioning" / host / "persist" / "secrets" / "boot" / "etc" / "ssh") }}
    ssh-keygen -t ed25519 -N "" -C "" -f {{ quote(".provisioning" / host / "persist" / "secrets" / "boot" / "etc" / "ssh" / HOSTKEY) }}

# Prepare for provisioning the `host`
prepare-provision host: (generate-ssh-host-key host) (update-ssh-host-key host) (update-secrets)

# Update the encrypted secrets in the repository (e.g. after changing the keys in .sops.yaml)
update-secrets:
    find . -name "secrets.yaml" -print0 | xargs -0 sops updatekeys --yes

# Update the key in `.sops.yaml` with the public key for the `host`.
update-ssh-host-key host:
    key=$(find {{ quote(".provisioning" / host) }} -name {{ quote(HOSTKEY + ".pub") }} -exec ssh-to-age -i {} \;) \
        yq -i {{ quote('(._keys[] | select(anchor == "' + host + '")) = strenv(key)') }} .sops.yaml
