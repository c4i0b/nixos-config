{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gnome-extensions-cli
    gnome-tweaks

    gnomeExtensions.appindicator
    (gnomeExtensions.copyous.overrideAttrs (old: {
      buildInputs = (builtins.filter (x: x.name or "" != "libgda-6.0.0") (old.buildInputs or [])) ++ [ pkgs.libgda5 ];
      preInstall = builtins.replaceStrings
        [ "${pkgs.libgda6}/lib/girepository-1.0" ]
        [ "${pkgs.libgda5}/lib/girepository-1.0" ]
        old.preInstall;
    }))
    gnomeExtensions.brightness-control-using-ddcutil
    gnomeExtensions.quick-settings-audio-panel
    gnomeExtensions.pop-shell
    gnomeExtensions.caffeine
  ];

  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "caio";
    };
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
            "appindicatorsupport@rgcjonas.gmail.com"
            "copyous@boerdereinar.dev"
            "display-brightness-ddcutil@themightydeity.github.com"
            "quick-settings-audio-panel@rayzeq.github.io"
            "pop-shell@system76.com"
            "caffeine@patapon.info"
          ];
        };
      };
    }
  ];
}
