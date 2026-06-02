# Placeholder file. On real install, regenerate with:
#   nixos-generate-config --root /mnt
# Then replace this file with the generated one.
{
  config,
  lib,
  pkgs,
  ...
}: {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/NEEDS_GENERATION";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd:1" "ssd" "discard=async" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/NEEDS_GENERATION";
    fsType = "ext4";
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/NEEDS_GENERATION";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
