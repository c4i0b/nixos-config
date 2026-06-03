{ config, lib, pkgs, ... }:
{
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
    gnomeExtensions.dash-to-dock
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
      settings =
        let
          inherit (lib.gvariant) mkTuple mkUint32 mkBoolean mkString;
        in
        {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            accent-color = "teal";
            font-name = "CaskaydiaCove Nerd Font 11";
            icon-theme = "Tela";
          };

          "org/gnome/desktop/background" = {
            picture-uri = "";
            picture-uri-dark = "";
            primary-color = "#000000";
          };

          "org/gnome/desktop/input-sources" = {
            sources = [ (mkTuple [ "xkb" "us+intl" ]) ];
            xkb-options = [ "altwin:swap_lalt_lwin" ];
          };

          "org/gnome/desktop/session" = {
            idle-delay = mkUint32 0;
          };

          "org/gnome/desktop/wm/keybindings" = {
            close = [ "<Super>q" ];
            toggle-maximized = [ "<Super>f" ];
            toggle-fullscreen = [ "<Super><Shift>f" ];
            move-to-center = [ "<Super>c" ];
            move-to-monitor-left = [ "<Super><Shift>Left" ];
            move-to-monitor-right = [ "<Super><Shift>Right" ];
            switch-to-workspace-left = [ "<Super><Control>Left" ];
            switch-to-workspace-right = [ "<Super><Control>Right" ];
            move-to-workspace-left = [ "<Super><Shift><Control>Left" ];
            move-to-workspace-right = [ "<Super><Shift><Control>Right" ];
            switch-applications = [ "<Alt>Tab" "<Super>Tab" ];
            switch-applications-backward = [ "<Shift><Alt>Tab" "<Shift><Super>Tab" ];
            cycle-windows-backward = [ ];
          } // (lib.genAttrs
            (map (i: "switch-to-workspace-${i}") (lib.range 1 9))
            (i: [ "<Super>${builtins.substring 6 1 i}" ])
          ) // (lib.genAttrs
            (map (i: "move-to-workspace-${i}") (lib.range 1 9))
            (i: [ "<Super><Shift>${builtins.substring 6 1 i}" ])
          );

          "org/gnome/shell/keybindings" = {
            toggle-overview = [ "<Super>a" ];
            show-screenshot-ui = [ "<Super><Shift>s" ];
            screenshot = [ "<Super><Shift>p" ];
            screenshot-window = [ "<Super><Shift>w" ];
            screen-brightness-up = [ "XF86MonBrightnessUp" ];
            screen-brightness-down = [ "XF86MonBrightnessDown" ];
          } // (lib.genAttrs
            (map (i: "switch-to-application-${i}") (lib.range 1 9))
            (_: [ ])
          );

          "org/gnome/mutter" = {
            dynamic-workspaces = true;
            auto-maximize = false;
          };

          "org/gnome/shell" = {
            enabled-extensions = [
              "appindicatorsupport@rgcjonas.gmail.com"
              "copyous@boerdereinar.dev"
              "display-brightness-ddcutil@themightydeity.github.com"
              "quick-settings-audio-panel@rayzeq.github.com"
              "dash-to-dock@micxgx.gmail.com"
              "pop-shell@system76.com"
              "caffeine@patapon.info"
            ];
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            email = [ ];
            volume-up = [ "XF86AudioRaiseVolume" ];
            volume-down = [ "XF86AudioLowerVolume" ];
            volume-mute = [ "XF86AudioMute" ];
            mic-mute = [ "XF86AudioMicMute" ];
            play = [ "XF86AudioPlay" ];
            stop = [ "XF86AudioStop" ];
            previous = [ "XF86AudioPrev" ];
            next = [ "XF86AudioNext" ];
            screensaver = [ "<Super>l" ];
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/file-manager/"
            ];
            "custom-keybindings/terminal/binding" = "<Super>Return";
            "custom-keybindings/terminal/command" = "kgx";
            "custom-keybindings/terminal/name" = "Terminal";
            "custom-keybindings/terminal/enable-in-lockscreen" = false;
            "custom-keybindings/file-manager/binding" = "<Super>e";
            "custom-keybindings/file-manager/command" = "nautilus";
            "custom-keybindings/file-manager/name" = "File manager";
            "custom-keybindings/file-manager/enable-in-lockscreen" = false;
          };

          "org/gnome/settings-daemon/plugins/power" = {
            power-saver-profile-on-low-battery = true;
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-ac-timeout = 900;
            sleep-inactive-battery-type = "suspend";
            sleep-inactive-battery-timeout = 300;
            idle-dim = true;
            idle-brightness = 30;
            power-button-action = "interactive";
          };

          "org/gnome/shell/extensions/pop-shell" = {
            tile-by-default = false;
          };

          "org/gnome/shell/extensions/display-brightness-ddcutil" = {
            button-location = 1.0;
            hide-system-indicator = true;
            show-display-name = false;
          };

          "org/gnome/shell/extensions/dash-to-dock" = {
            dock-position = "BOTTOM";
            hot-keys = false;
            hotkeys-show-dock = false;
            hotkeys-overlay = false;
          };

          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "list-view";
          };
          "org/gnome/nautilus/list-view" = {
            use-tree-view = true;
            default-zoom-level = "medium";
          };
        };
    }
  ];
}
