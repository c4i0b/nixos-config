{ config, lib, pkgs, ... }:
let
  niriConfigFile = pkgs.writeText "niri-config.kdl" ''
    // Niri configuration
    // Managed by NixOS — edit this file in the flake and rebuild.
    // To override locally without touching the flake, manage
    // ~/.config/niri/config.kdl via stow and use:
    //   include optional=true "/etc/niri/config.kdl"

    input {
        keyboard {
            xkb {
                layout "us"
                variant "intl"
            }
        }
        touchpad {
            tap true
            natural-scroll true
            click-method "clickfinger"
            dwt true
        }
    }

    layout {
        gaps 16
        border {
            enable true
            width 4
        }
        focus-ring {
            enable false
        }
        shadow {
            enable true
        }
        always-center-single-column true
    }

    prefer-no-csd true

    hotkey-overlay {
        skip-at-startup false
    }

    binds {
        // Terminal
        Mod+T spawn "kitty"
        // Launcher
        Mod+D spawn "fuzzel"
        // Close window
        Mod+Q close-window
        // Lock screen
        Mod+L spawn "swaylock"
        // Screenshots
        Print screenshot-screen
        Mod+Shift+S screenshot
        // Navigation
        Mod+Left focus-column-left
        Mod+Down focus-window-down
        Mod+Up focus-window-up
        Mod+Right focus-column-right
        // Workspaces
        Mod+1 focus-workspace 1
        Mod+2 focus-workspace 2
        Mod+3 focus-workspace 3
        Mod+4 focus-workspace 4
        Mod+5 focus-workspace 5
        Mod+Shift+1 move-column-to-workspace 1
        Mod+Shift+2 move-column-to-workspace 2
        Mod+Shift+3 move-column-to-workspace 3
        Mod+Shift+4 move-column-to-workspace 4
        Mod+Shift+5 move-column-to-workspace 5
        // Volume
        XF86AudioRaiseVolume spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"
        XF86AudioLowerVolume spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        XF86AudioMute spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        // Brightness
        XF86MonBrightnessUp spawn-sh "brightnessctl set 10%+"
        XF86MonBrightnessDown spawn-sh "brightnessctl set 10%-"
    }

    window-rules [
        {
            draw-border-with-background false
            geometry-corner-radius {
                top-left 8.0
                top-right 8.0
                bottom-left 8.0
                bottom-right 8.0
            }
            clip-to-geometry true
        }
    ]

    spawn-at-startup [
        { command [ "noctalia-shell" ] }
    ]

    environment {
        NIXOS_OZONE_WL "1"
    }
  '';
in {
  programs.niri.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  security.polkit.enable = true;

  security.pam.services.swaylock = { };

  systemd.user.services.polkit-niri = {
    description = "PolicyKit Authentication Agent";
    wantedBy = [ "niri.service" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  services.displayManager = {
    gdm.enable = true;
    autoLogin = {
      enable = true;
      user = "caio";
    };
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    kitty
    fuzzel
    swaylock
    swayidle
    brightnessctl
    cliphist
    wlr-randr
  ];

  system.activationScripts.niri-config = lib.mkAfter ''
    if [ ! -f /home/caio/.config/niri/config.kdl ]; then
      mkdir -p /home/caio/.config/niri
      cp ${niriConfigFile} /home/caio/.config/niri/config.kdl
      chown caio:users /home/caio/.config/niri/config.kdl
    fi
  '';
}
