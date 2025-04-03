# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
#
# Requires [just](https://just.systems).

[private]
[script]
[doc('Generate a disk password in DESTINATION.

Does nothing if DESTINATION exists already.')]
generate-disk-password DESTINATION:
    if [ -s {{ quote(DESTINATION) }} ]; then
        >&2 printf '[%sEXISTS%s    ] Disk Encryption Password in %s\n' {{ quote(style("warning")) }} {{ quote(NORMAL) }} {{ quote(clean(DESTINATION)) }}
    else
        >&2 printf '[%sGENERATE%s  ] Disk Encryption Password in %s\n' {{ quote(style("command")) }} {{ quote(NORMAL) }} {{ quote(clean(DESTINATION)) }}
        mkdir -p {{ quote(parent_directory(DESTINATION)) }}
        pwgen -s 32 1 > {{ quote(clean(DESTINATION)) }}
        chmod 0600 {{ quote(clean(DESTINATION)) }}
    fi

[private]
[script]
[doc('Generate a SSH key with COMMENT in DESTINATION.

Does nothing if  DESTINATION exists already.')]
generate-ssh-key COMMENT DESTINATION:
    if [ -s {{ quote(DESTINATION) }} ]; then
        >&2 printf '[%sEXISTS%s    ] SSH Key: %s in %s\n' {{ quote(style("warning")) }} {{ quote(NORMAL) }} {{ quote(COMMENT) }} {{ quote(clean(DESTINATION)) }}
    else
        >&2 printf '[%sGENERATE%s  ] SSH Key: %s in %s\n' {{ quote(style("command")) }} {{ quote(NORMAL) }} {{ quote(COMMENT) }} {{ quote(clean(DESTINATION)) }}
        mkdir -p {{ quote(parent_directory(clean(DESTINATION))) }}
        ssh-keygen -t ed25519 -N "" -C {{ quote(COMMENT) }} -f {{ quote(clean(DESTINATION)) }}
    fi


[private]
[script]
[doc('Update the SOPS_YAML file with the new PUBKEY.

The key is marked with the HOST anchor, and secrets in SECRETS_YAML are updated.')]
update-sops-key HOST PUBKEY SOPS_YAML SECRETS_YAML:
    export AGE_KEY=$(ssh-to-age -i {{ quote(clean(PUBKEY)) }})
    previous=$(yq {{ quote('._keys[] | select(anchor == "' + HOST + '")') }} {{ quote(clean(SOPS_YAML)) }})

    if [ "${previous}" = "${AGE_KEY}" ]; then
        >&2 printf '[%sUP-TO-DATE%s] SOPS key `%s` in .sops.yaml: %s\n' {{ quote(style("warning")) }} {{ quote(NORMAL) }} {{ quote(HOST) }} "${AGE_KEY}"
    else
        has=$(yq {{ quote('._keys | any_c(anchor == "' + HOST + '")') }} {{ quote(clean(SOPS_YAML)) }})
        if [ "${has}" = "true" ]; then
            >&2 printf '[%sUPDATE%s    ] SOPS key `%s` in .sops.yaml: %s\n' {{ quote(style("command")) }} {{ quote(NORMAL) }} {{ quote(HOST) }} "${AGE_KEY}"
            yq -i {{ quote('(._keys[] | select(anchor == "' + HOST + '")) = strenv(AGE_KEY)') }} {{ quote(clean(SOPS_YAML)) }}
        else
            >&2 printf '[%sINSERT%s    ] SOPS key `%s` in .sops.yaml: %s\n' {{ quote(style("command")) }} {{ quote(NORMAL) }} {{ quote(HOST) }} "${AGE_KEY}"
            yq -i {{ quote('._keys += strenv(AGE_KEY) | (._keys[-1] anchor="' + HOST +  '")') }} {{ quote(clean(SOPS_YAML)) }}
        fi

        if [ -s {{ quote(clean(SECRETS_YAML)) }} ]; then
            >&2 printf '[%sUPDATE%s    ] Secrets in %s\n' {{ quote(style("command")) }} {{ quote(NORMAL) }} {{ quote(clean(SECRETS_YAML)) }}
            sops updatekeys --yes {{ quote(clean(SECRETS_YAML)) }}
        fi
    fi
