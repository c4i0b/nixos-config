# KDE Plasma 6 desktop environment.
{ config, lib, pkgs, ... }: let
  inherit (lib) mkForce concatMapStringsSep;

  kdeglobals = pkgs.writeText "kdeglobals" ''
    [General]
    Name=CaskaydiaCove Nerd Font
    Size=11

    [Icons]
    Theme=Numix-Circle

    [KDE]
    ColorScheme=BreezeDark
    widgetStyle=Breeze

    [Mainwindow]
    ToolbarFontSize=11
  '';

  kwinrc = pkgs.writeText "kwinrc" ''
    [Compositing]
    Enabled=true
    OpenGLIsUnsafe=false

    [Desktops]
    Number=4

    [Windows]
    SnapOnlyMaximizing=false
    BorderSnapZone=0

    [Effect-PresentWindows]
    BorderActivateAll=9

    [org.kde.kdecoration2]
    library=org.kde.kwin.decoration.breezedark
  '';

  kglobalshortcutsrc = pkgs.writeText "kglobalshortcutsrc" ''
    [kwin]
    Window Close=Meta+Q,Meta+Q,Close Window
    Window Maximize=Meta+F,Meta+F,Maximize Window
    Window Fullscreen=Meta+Shift+F,Meta+Shift+F,Make Window Fullscreen
    MoveMouseToCenter=Meta+C,Meta+C,Move Mouse to Center
    Overview=Meta+A,Meta+A,Toggle Overview
    Switch to Desktop 1=Meta+1,Meta+1,Switch to Desktop 1
    Switch to Desktop 2=Meta+2,Meta+2,Switch to Desktop 2
    Switch to Desktop 3=Meta+3,Meta+3,Switch to Desktop 3
    Switch to Desktop 4=Meta+4,Meta+4,Switch to Desktop 4
    Switch to Desktop 5=Meta+5,Meta+5,Switch to Desktop 5
    Switch to Desktop 6=Meta+6,Meta+6,Switch to Desktop 6
    Switch to Desktop 7=Meta+7,Meta+7,Switch to Desktop 7
    Switch to Desktop 8=Meta+8,Meta+8,Switch to Desktop 8
    Switch to Desktop 9=Meta+9,Meta+9,Switch to Desktop 9
    Window to Desktop 1=Meta+Shift+1,Meta+Shift+1,Window to Desktop 1
    Window to Desktop 2=Meta+Shift+2,Meta+Shift+2,Window to Desktop 2
    Window to Desktop 3=Meta+Shift+3,Meta+Shift+3,Window to Desktop 3
    Window to Desktop 4=Meta+Shift+4,Meta+Shift+4,Window to Desktop 4
    Window to Desktop 5=Meta+Shift+5,Meta+Shift+5,Window to Desktop 5
    Window to Desktop 6=Meta+Shift+6,Meta+Shift+6,Window to Desktop 6
    Window to Desktop 7=Meta+Shift+7,Meta+Shift+7,Window to Desktop 7
    Window to Desktop 8=Meta+Shift+8,Meta+Shift+8,Window to Desktop 8
    Window to Desktop 9=Meta+Shift+9,Meta+Shift+9,Window to Desktop 9

    [plasmashell]
    activate task manager entry 1=none,none,Activate Task Manager Entry 1
    activate task manager entry 2=none,none,Activate Task Manager Entry 2
    activate task manager entry 3=none,none,Activate Task Manager Entry 3
    activate task manager entry 4=none,none,Activate Task Manager Entry 4
    activate task manager entry 5=none,none,Activate Task Manager Entry 5
    activate task manager entry 6=none,none,Activate Task Manager Entry 6
    activate task manager entry 7=none,none,Activate Task Manager Entry 7
    activate task manager entry 8=none,none,Activate Task Manager Entry 8
    activate task manager entry 9=none,none,Activate Task Manager Entry 9
    manage activities=none,none,Show Activity Switcher
    next activity=none,none,Walk through activities

    [org.kde.spectacle]
    RecordScreen=none,none,Start Recording
    RecordWindow=none,none,Record Current Window
    RecordRegion=Meta+Shift+R,Meta+Shift+R,Record a Rectangular Region
    Screenshot=Meta+Shift+S,Meta+Shift+S,Capture the Entire Screen
    ScreenshotCurrentScreen=Meta+Shift+P,Meta+Shift+P,Capture the Current Screen
    ScreenshotWindowUnderCursor=Meta+Shift+W,Meta+Shift+W,Capture the Active Window

    [services][com.mitchellh.ghostty.desktop]
    _launch=Meta+Return\tCtrl+Escape,Meta+Return\tCtrl+Escape,Open Ghostty

    [services][org.kde.dolphin.desktop]
    _launch=Meta+E,Meta+E,Open Dolphin
  '';

in {
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
    kdePackages.kmahjongg
    kdePackages.kpat
  ];

  environment.systemPackages = with pkgs; [
    ghostty
    numix-icon-theme-circle
    nerd-fonts.caskaydia-cove
    kdePackages.krohnkite
    kdePackages.dynamic-workspaces
  ];

  programs = {
    firefox.nativeMessagingHosts.packages = [
      pkgs.kdePackages.plasma-browser-integration
    ];
    chromium.enablePlasmaBrowserIntegration = true;
    ssh.askPassword = mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
  };

  systemd.tmpfiles.rules = [
    "d /home/caio/.config/kdedefaults 0755 caio users -"
    "L+ /home/caio/.config/kdedefaults/kdeglobals - - - - ${kdeglobals}"
    "L+ /home/caio/.config/kdedefaults/kwinrc - - - - ${kwinrc}"
    "L+ /home/caio/.config/kdedefaults/kglobalshortcutsrc - - - - ${kglobalshortcutsrc}"
  ];
}
