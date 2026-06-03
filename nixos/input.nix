{ lib, pkgs, ... }:
let
  hide = name: desktopName: pkgs.makeDesktopItem {
    inherit name desktopName;
    type = "Application";
    noDisplay = true;
  };
in {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.settings = {
      inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us(intl)";
          DefaultIM = "keyboard-us-intl";
        };
        "Groups/0/Items/0" = {
          Name = "keyboard-us-intl";
          Layout = "";
        };
        GroupOrder = {
          "0" = "Default";
        };
      };
      addons = {
        wayland = {
          globalSection.AllowOverridingSystemXKBSettings = "False";
        };
        xcb = {
          globalSection.AllowOverridingSystemXKBSettings = "False";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    (lib.hiPrio (makeDesktopItem {
      name = "org.fcitx.Fcitx5";
      desktopName = "Fcitx 5";
      genericName = "Input Method";
      exec = "${fcitx5}/bin/fcitx5";
      type = "Application";
      categories = [ "System" "Utility" ];
      noDisplay = true;
    }))
    (lib.hiPrio (makeDesktopItem {
      name = "fcitx5-configtool";
      desktopName = "Fcitx 5 Configuration";
      genericName = "Input Method Configuration";
      exec = "${fcitx5}/bin/fcitx5-configtool";
      type = "Application";
      noDisplay = true;
    }))
    (lib.hiPrio (makeDesktopItem {
      name = "org.fcitx.fcitx5-config-qt";
      desktopName = "Fcitx 5 Configuration (Qt)";
      exec = "${fcitx5}/bin/fcitx5-config-qt";
      type = "Application";
      noDisplay = true;
    }))
    (lib.hiPrio (hide "org.fcitx.fcitx5-qt5-gui-wrapper" "Fcitx 5 Qt5 GUI"))
    (lib.hiPrio (hide "org.fcitx.fcitx5-qt6-gui-wrapper" "Fcitx 5 Qt6 GUI"))
    (lib.hiPrio (hide "org.fcitx.fcitx5-migrator" "Fcitx 5 Migrator"))
    (lib.hiPrio (hide "kcm_fcitx5" "Fcitx 5 KCM"))
    (lib.hiPrio (hide "kbd-layout-viewer5" "Keyboard Layout Viewer"))
    (lib.hiPrio (hide "fcitx5-wayland-launcher" "Fcitx 5 Wayland Launcher"))
  ];

  environment.etc."xdg/autostart/org.fcitx.Fcitx5.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Fcitx 5
    Exec=fcitx5 --disable notificationitem,classicui,notification,imselector
  '';
}
