{pkgs, ...}: {
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    # flatpak.enable = true;
    fwupd.enable = true;
    upower.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    i2c.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    cascadia-code
  ];
}
