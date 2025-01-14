# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{ lib, ... }:
{
  _file = ./openssh.nix;

  services.openssh = {
    # The provisioning of host keys is different depending on whether or not
    # `system.etc.overlay.enable` is true or false. This is annoying, because
    # changing host keys require re-encryption of the repository secrets.
    # The easiest way to sidestep the issue is to move the host keys out of
    # `/etc/`.
    hostKeys = lib.mkDefault [
      {
        path = "/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];
  };
}
