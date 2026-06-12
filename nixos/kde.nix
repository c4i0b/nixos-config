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

  environment.etc."xdg/kdeglobals".text = lib.generators.toINI { } {
    General.ColorScheme = "QogirDark";
    Icons.Theme = "Qogir";
    KDE.LookAndFeelPackage = "com.github.vinceliuice.ChromeOS-dark";
  };

  environment.etc."xdg/plasma-org.kde.plasma.desktop-appletsrc".text = lib.generators.toINI { } {
    "org.kde.plasma.desktop".WidgetStyle = "org.kde.breeze.dark";
  };

  environment.etc."xdg/kwinrc".text = lib.generators.toINI { } {
    Wayland.InputMethod = "${pkgs.qt6Packages.fcitx5-with-addons.override { addons = []; }}/share/applications/org.fcitx.Fcitx5.desktop";
  };

  # Enable OCR text extraction in Spectacle (screenshots)
  environment.systemPackages = [
    (pkgs.kdePackages.spectacle.override {
      tesseractLanguages = [ "eng" "por" ];
    })
  ];
}
