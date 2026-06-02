{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnome-extensions-cli
    gnome-tweaks

    gnomeExtensions.copyous
    gnomeExtensions.brightness-control-using-ddcutil
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

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            "copyous@boerdereinar.dev"
            "display-brightness-ddcutil@themightydeity.github.com"
          ];
        };
      };
    }
  ];
}
