# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  lib,
  ...
}:
let
  cfg = config.croissant.disk;
  inherit (lib) mkEnableOption;

  # Because of https://github.com/nix-community/disko/issues/678 we have to duplicate this here.
  partition = lib.attrsets.optionalAttrs (cfg.partitionType == "gpt") {
    esp = {
      label = "boot";
      name = "ESP";
      priority = 1;
      size = "500M";
      type = "EF00";
      content = {
        format = "vfat";
        mountpoint = "/boot";
        mountOptions = [
          "defaults"
          "umask=0077"
        ];
        type = "filesystem";
      };
    };
  };
in
{
  _file = ./ext4.nix;

  options.croissant.disk = {
    ext4 = {
      enable = mkEnableOption "use ext4 for the disk configuration";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.ext4.enable) {
    disko = {
      devices = {
        disk = {
          disk1 = {
            name = "main";
            type = "disk";
            device = lib.mkDefault cfg.device;
            content = {
              type = cfg.partitionType;
              partitions = partition // {
                root = {
                  size = "100%";
                  priority = 2;
                  content = {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
