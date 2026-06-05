# GPU drivers and graphics configuration.
{config, pkgs, ...}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime.offload.enable = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

}
