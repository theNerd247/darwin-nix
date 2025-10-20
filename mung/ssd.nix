{ flake =
  { # enable ntfs support
    boot.supportedFilesystems = [ "exfat" ];

    fileSystems."/mnt/backup" =
    { device = "/dev/disk/by-uuid/E841-9F80";
      fsType = "exfat";
      options = [ "rw" "uid=1000"];
    };
  };
}
