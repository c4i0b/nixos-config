# Bootloader, kernel, and initrd configuration.
{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.unstablePkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    supportedFilesystems = ["btrfs" "ntfs"];
    initrd = {
      systemd.enable = true;
    };
  };
}
