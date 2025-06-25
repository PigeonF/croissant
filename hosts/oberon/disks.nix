_: {
  _file = ./disks.nix;

  config = {
    disko = {
      devices = {
        disk = {
          vda = {
            device = "/dev/nvme0n1";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                boot = {
                  name = "boot";
                  size = "1M";
                  type = "EF02";
                };
                esp = {
                  name = "ESP";
                  size = "500M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
                primary = {
                  size = "100%";
                  content = {
                    type = "lvm_pv";
                    vg = "mainpool";
                  };
                };
              };
            };
          };
        };
        lvm_vg = {
          mainpool = {
            type = "lvm_vg";
            lvs = {
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [
                    "defaults"
                  ];
                };
              };
            };
          };
        };
      };
    };
  };
}
