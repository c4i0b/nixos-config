{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnome-extensions-cli
    gnome-tweaks
  ];

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    totem
    yelp
    simple-scan
    snapshot
  ];
}
