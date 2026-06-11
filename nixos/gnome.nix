# Gnome Desktop Environment: extensions, settings, keybindings, and excluded packages.
{ config, lib, pkgs, ... }:
let
  inherit (lib.gvariant) mkInt32 mkTuple;
in {
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
    gnomeExtensions.pip-on-top
  ];

  services = {
    desktopManager.gnome.enable = true;
    desktopManager.gnome.sessionPath = [ pkgs.gtk3 ];
  };

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    geary
    totem
    yelp
    simple-scan
    snapshot
    gnome-contacts
    gnome-maps
    gnome-weather
    cheese
    gnome-tour
  ];

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/settings-daemon/plugins/power" = {
          sleep-inactive-ac-timeout = mkInt32 0;
          sleep-inactive-battery-timeout = mkInt32 0;
        };
      };
    }
    {
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "copyous@boerdereinar.dev"
            "display-brightness-ddcutil@themightydeity.github.com"
            "quick-settings-audio-panel@rayzeq.github.com"
            "dash-to-dock@micxgx.gmail.com"
            "pop-shell@system76.com"
            "caffeine@patapon.info"
            "pip-on-top@rafostar.github.com"
          ];
          always-show-log-out = true;
        };
      };
    }
    {
      settings = {
        "org/gnome/desktop/input-sources" = {
          sources = [ (mkTuple [ "xkb" "us+intl" ]) ];
          xkb-options = [ "altwin:swap_lalt_lwin" ];
        };
      };
      locks = [
        "/org/gnome/desktop/input-sources/sources"
        "/org/gnome/desktop/input-sources/xkb-options"
      ];
    }
    {
      keyfiles = with pkgs; [
        (runCommand "gnome-dconf-keyfiles" {
          preferLocalBuild = true;
        } (let
          kdir = "keyfiles";
        in ''
          mkdir -p ${kdir}

          cat > ${kdir}/00-appearance.conf << 'CONF'
          [org/gnome/desktop/interface]
          color-scheme='prefer-dark'
          accent-color='teal'
          font-name='CaskaydiaCove Nerd Font 11'
          icon-theme='Qogir'

          [org/gnome/desktop/background]
          picture-uri=""
          picture-uri-dark=""
          primary-color="#000000"
          CONF

          cat > ${kdir}/01-keybindings.conf << 'CONF'
          [org/gnome/desktop/wm/keybindings]
          close=['<Super>q']
          toggle-maximized=['<Super>f']
          toggle-fullscreen=['<Super><Shift>f']
          move-to-center=['<Super>c']
          move-to-monitor-left=['<Super><Control><Shift>Left']
          move-to-monitor-right=['<Super><Control><Shift>Right']
          switch-to-workspace-left=['<Super><Control>Left']
          switch-to-workspace-right=['<Super><Control>Right']
          move-to-workspace-left=['<Super><Shift><Control>Left']
          move-to-workspace-right=['<Super><Shift><Control>Right']
          switch-applications=['<Alt>Tab', '<Super>Tab']
          switch-applications-backward=['<Shift><Alt>Tab', '<Shift><Super>Tab']
          cycle-windows-backward=@as []
          switch-to-workspace-1=['<Super>1']
          switch-to-workspace-2=['<Super>2']
          switch-to-workspace-3=['<Super>3']
          switch-to-workspace-4=['<Super>4']
          switch-to-workspace-5=['<Super>5']
          switch-to-workspace-6=['<Super>6']
          switch-to-workspace-7=['<Super>7']
          switch-to-workspace-8=['<Super>8']
          switch-to-workspace-9=['<Super>9']
          move-to-workspace-1=['<Super><Shift>1']
          move-to-workspace-2=['<Super><Shift>2']
          move-to-workspace-3=['<Super><Shift>3']
          move-to-workspace-4=['<Super><Shift>4']
          move-to-workspace-5=['<Super><Shift>5']
          move-to-workspace-6=['<Super><Shift>6']
          move-to-workspace-7=['<Super><Shift>7']
          move-to-workspace-8=['<Super><Shift>8']
          move-to-workspace-9=['<Super><Shift>9']

          [org/gnome/shell/keybindings]
          toggle-overview=['<Super>a']
          show-screenshot-ui=['<Super><Shift>s']
          screenshot=['<Super><Shift>p']
          screenshot-window=['<Super><Shift>w']
          screen-brightness-up=['XF86MonBrightnessUp']
          screen-brightness-down=['XF86MonBrightnessDown']
          switch-to-application-1=@as []
          switch-to-application-2=@as []
          switch-to-application-3=@as []
          switch-to-application-4=@as []
          switch-to-application-5=@as []
          switch-to-application-6=@as []
          switch-to-application-7=@as []
          switch-to-application-8=@as []
          switch-to-application-9=@as []

          [org/gnome/mutter]
          dynamic-workspaces=true
          auto-maximize=false
          edge-tiling=false

          [org/gnome/mutter/keybindings]
          toggle-tiled-left=@as []
          toggle-tiled-right=@as []
          CONF

          cat > ${kdir}/02-media-keys.conf << 'CONF'
          [org/gnome/settings-daemon/plugins/media-keys]
          email=@as []
          volume-up=['XF86AudioRaiseVolume']
          volume-down=['XF86AudioLowerVolume']
          volume-mute=['XF86AudioMute']
          mic-mute=['XF86AudioMicMute']
          play=['XF86AudioPlay']
          stop=['XF86AudioStop']
          previous=['XF86AudioPrev']
          next=['XF86AudioNext']
          screensaver=['<Super>l']
          custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/file-manager/']

          [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/terminal]
          binding='<Super>Return'
          command='kgx'
          name='Terminal'
          enable-in-lockscreen=false

          [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/file-manager]
          binding='<Super>e'
          command='nautilus'
          name='File manager'
          enable-in-lockscreen=false

          [org/gnome/settings-daemon/plugins/power]
          power-saver-profile-on-low-battery=true
          sleep-inactive-battery-type='suspend'
          sleep-inactive-battery-timeout=uint32 300
          idle-dim=true
          idle-brightness=uint32 30
          power-button-action='interactive'

          [org/gnome/desktop/session]
          idle-delay=uint32 900
          lock-enabled=false
          lock-delay=uint32 0
          CONF

          cat > ${kdir}/03-extensions.conf << 'CONF'
          [org/gnome/shell/extensions/pop-shell]
          tile-by-default=true
          gap-inner=uint32 0
          gap-outer=uint32 0
          tile-enter=['<Super>r']
          toggle-stacking=@as []
          toggle-stacking-global=@as []
          stacking-with-mouse=false
          management-orientation=['e']
          focus-left=['<Super>Left','<Super>h','<Super>a']
          focus-right=['<Super>Right','<Super>l','<Super>d']
          focus-up=['<Super>Up','<Super>k','<Super>w']
          focus-down=['<Super>Down','<Super>j','<Super>s']
          tile-move-left=['<Shift>Left','<Shift>KP_Left','<Shift>h','<Shift>a']
          tile-move-down=['<Shift>Down','<Shift>KP_Down','<Shift>j','<Shift>s']
          tile-move-up=['<Shift>Up','<Shift>KP_Up','<Shift>k','<Shift>w']
          tile-move-right=['<Shift>Right','<Shift>KP_Right','<Shift>l','<Shift>d']
          tile-resize-left=['Left','KP_Left','h','a']
          tile-resize-down=['Down','KP_Down','j','s']
          tile-resize-up=['Up','KP_Up','k','w']
          tile-resize-right=['Right','KP_Right','l','d']
          tile-swap-left=['<Primary>Left','<Primary>KP_Left','<Primary>h','<Primary>a']
          tile-swap-down=['<Primary>Down','<Primary>KP_Down','<Primary>j','<Primary>s']
          tile-swap-up=['<Primary>Up','<Primary>KP_Up','<Primary>k','<Primary>w']
          tile-swap-right=['<Primary>Right','<Primary>KP_Right','<Primary>l','<Primary>d']
          tile-move-left-global=['<Super><Shift>Left']
          tile-move-right-global=['<Super><Shift>Right']
          tile-move-up-global=['<Super><Shift>Up']
          tile-move-down-global=['<Super><Shift>Down']
          toggle-tiling=['<Super>t']
          pop-monitor-left=@as []
          pop-monitor-right=@as []
          pop-monitor-up=@as []
          pop-monitor-down=@as []

          [org/gnome/shell/extensions/display-brightness-ddcutil]
          button-location=1
          hide-system-indicator=true
          position-system-menu=3.0
          show-display-name=false

          [org/gnome/shell/extensions/dash-to-dock]
          dock-position='BOTTOM'
          hot-keys=false
          hotkeys-show-dock=false
          hotkeys-overlay=false

          [org/gnome/shell/extensions/pip-on-top]
          stick=true
          CONF

          cat > ${kdir}/04-nautilus.conf << 'CONF'
          [org/gnome/nautilus/preferences]
          default-folder-viewer='list-view'

          [org/gnome/nautilus/list-view]
          use-tree-view=true
          default-zoom-level='medium'
          CONF

          cp -r ${kdir} $out
        ''))
      ];
    }
  ];
}
