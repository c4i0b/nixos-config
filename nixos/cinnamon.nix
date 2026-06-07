{ pkgs, ... }:
let
  keybindings-script = pkgs.writeShellScript "cinnamon-custom-keybindings" ''
    dconf write /org/cinnamon/desktop/keybindings/custom-list "['custom0', 'custom1', 'custom2']"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/name "'Flameshot screenshot'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/binding "['<Super><Shift>s']"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/command "'flameshot gui'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/name "'CopyQ clipboard'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/binding "['<Super>v']"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom1/command "'copyq show'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/name "'Window screenshot'"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/binding "['<Super><Shift>w']"
    dconf write /org/cinnamon/desktop/keybindings/custom-keybindings/custom2/command "'gnome-screenshot -w -c'"
  '';
in {
  services.xserver.desktopManager.cinnamon.enable = true;

  environment.cinnamon.excludePackages = with pkgs; [
    celluloid
    warpinator
  ];

  environment.systemPackages = with pkgs; [
    copyq
    flameshot
  ];

  environment.etc."xdg/flameshot/flameshot.ini".text = ''
    [General]
    showDesktopNotification=false
    disabledTrayIcon=true
  '';

  environment.etc."xdg/autostart/cinnamon-custom-keybindings.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Cinnamon Custom Keybindings
    Exec=${keybindings-script}
    OnlyShowIn=X-Cinnamon;
    StartupNotify=false
    X-GNOME-Autostart-Phase=Initialization
  '';

  environment.etc."xdg/autostart/copyq.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=CopyQ Clipboard Manager
    Exec=copyq --start-server
    OnlyShowIn=X-Cinnamon;
    StartupNotify=false
    X-GNOME-Autostart-Phase=Applications
  '';

  environment.sessionVariables.GTK_IM_MODULE = "xim";

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/cinnamon/desktop/interface" = {
          font-name = "CaskaydiaCove Nerd Font 11";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Numix-Circle";
        };

        "org/gnome/desktop/interface" = {
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Numix-Circle";
          color-scheme = "prefer-dark";
        };

        "org/x/apps/portal" = {
          color-scheme = "prefer-dark";
        };

        "org/cinnamon/theme" = {
          name = "Mint-Y-Dark-Red";
        };

        "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
          font = "Cascadia Mono 12";
          use-system-font = false;
        };
      };
    }
  ];
}
