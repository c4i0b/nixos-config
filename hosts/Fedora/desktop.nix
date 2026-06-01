# GNOME desktop environment
{ pkgs, ... }: {
  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
      };
      videoDrivers = ["nvidia"];
    };

    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
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

    flatpak.enable = true;
    fwupd.enable = true;

    udev.packages = with pkgs; [steam];
  };

  programs = {
    fish.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    cascadia-code
  ];

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    totem
    yelp
    simple-scan
    snapshot
  ];
}
