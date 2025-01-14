# SPDX-FileCopyrightText: 2025 Jonas Fierlings <fnoegip@gmail.com>
#
# SPDX-License-Identifier: 0BSD
{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.croissant.disk;
  inherit (lib) mkEnableOption mkOption types;
in
{
  _file = ./default.nix;

  imports = [
    inputs.disko.nixosModules.disko
    ./ext4.nix
  ];

  options.croissant = {
    disk = {
      enable = mkEnableOption "a default disk configuration";

      device = mkOption {
        default = "/dev/sda";
        example = "/dev/nvme0n1";
        description = ''
          The path to the main disk device.
        '';
        type = types.str;
      };

      partitionType = mkOption {
        default = "gpt";
        description = ''
          The partition scheme to use.
        '';
        type = types.enum [ "gpt" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.lists.any (submodule: submodule.enable) (
          builtins.attrValues { inherit (cfg) ext4; }
        );
        message = ''
          Croissant disk setup enabled, but none of the filesystem formats are enabled.
          Enable {option}`croissant.disk.ext4.enable`.
        '';
      }
    ];

    # https://github.com/nix-community/disko/issues/678
    # disko = {
    #   devices = {
    #     disk = {
    #       disk1 = {
    #         name = "main";
    #         type = "disk";
    #         device = lib.mkDefault cfg.device;
    #         content = {
    #           type = cfg.partitionType;
    #           partitions = lib.attrsets.optionalAttrs (cfg.partitionType == "gpt") {
    #             esp = {
    #               label = "boot";
    #               name = "ESP";
    #               priority = 1;
    #               size = "500M";
    #               type = "EF00";
    #               content = {
    #                 format = "vfat";
    #                 mountpoint = "/boot";
    #                 mountOptions = [
    #                   "defaults"
    #                   "umask=0077"
    #                 ];
    #                 type = "filesystem";
    #               };
    #             };
    #           };
    #         };
    #       };
    #     };
    #   };
    # };
  };
}
