{config, pkgs, ...}: {
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = ["btrfs" "ntfs"];
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];
    initrd = {
      systemd.enable = true;
      kernelModules = ["nvme" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    };
    kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime.offload.enable = false;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  systemd.services.nvidia-powerd.enable = true;
}
