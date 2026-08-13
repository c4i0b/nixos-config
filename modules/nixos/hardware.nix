{ config, pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    open = true;
    branch = "latest";
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  # Disable HDA Intel power saving (idle audio pops).
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  fileSystems."/mnt/KingFast_EXT4" = {
    device = "/dev/disk/by-label/KingFast_EXT4";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # Layered on top of hardware-configuration.nix.
  fileSystems."/".options = [ "compress=zstd" "noatime" ];
  fileSystems."/home".options = [ "subvol=home" "compress=zstd" "noatime" ];
  fileSystems."/nix".options = [ "subvol=nix" "compress=zstd" "noatime" ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  services.btrfs.autoScrub.enable = true;

  hardware.bluetooth.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="a728", ATTR{power/control}="on"
  '';
}
