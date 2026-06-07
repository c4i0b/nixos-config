# Desktop services shared across all DEs/compositors.
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
      wireplumber.configPackages = [
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/90-audio-disable.conf" ''
          monitor.alsa.rules = [
            {
              matches = [ { device.vendor.id = "~0x10de.*" } ]
              actions = { update-props = { device.disabled = true } }
            }
            {
              matches = [ { device.name = "~.*MCHOSE_X9.*" } ]
              actions = { update-props = { device.profile-set = "analog-only.conf" } }
            }
          ]
        '')
      ];
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
    source-sans
    inter
  ];

  environment.systemPackages = with pkgs; [
    adw-gtk3
    numix-icon-theme-circle
  ];

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=adw-gtk3-dark
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=adw-gtk3-dark
  '';
}
