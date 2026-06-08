  # KDE Plasma 6 desktop environment.
  { config, lib, pkgs, ... }:
  {
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.khelpcenter
    kdePackages.konqueror
    kdePackages.kmail
    kdePackages.akregator
    kdePackages.korganizer
    kdePackages.kontact
    kdePackages.kaddressbook
    kdePackages.ktnef
    kdePackages.discover
    kdePackages.kmahjongg
    kdePackages.kpat
  ];

  environment.etc."xdg/kwinrc".text = lib.generators.toINI { } {
    Wayland.InputMethod = "${pkgs.ibus-with-plugins.override { plugins = []; }}/share/applications/org.freedesktop.IBus.Panel.Wayland.Gtk3.desktop";
  };
}
