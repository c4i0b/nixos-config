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
      wireplumber.extraConfig."90-audio-disable" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "~alsa_card.pci-0000_01_00.*"; }
            ];
            actions = {
              "update-props" = {
                "device.disabled" = true;
              };
            };
          }
          {
            matches = [
              { "node.name" = "~alsa_output.*.iec958*"; }
            ];
            actions = {
              "update-props" = {
                "node.disabled" = true;
              };
            };
          }
        ];
      };
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

  environment.systemPackages = with pkgs; [
    adw-gtk3
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
