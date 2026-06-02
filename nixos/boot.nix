{pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["btrfs" "ntfs"];
    initrd = {
      systemd.enable = true;
    };
  };
}
