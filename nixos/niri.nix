# Niri Wayland compositor: packages, services, and settings.
{ config, lib, pkgs, ... }:
{
  programs.niri.enable = true;

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

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/nemo/list-view" = {
          enable-folder-expansion = true;
          default-zoom-level = "standard";
        };
        "org/nemo/preferences" = {
          default-folder-viewer = "list-view";
          "menu-config/background-menu-open-as-root" = false;
          "menu-config/background-menu-open-in-terminal" = false;
          "menu-config/selection-menu-open-as-root" = false;
          "menu-config/selection-menu-open-in-terminal" = false;
        };
      };
    }
  ];

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    ghostty
    nemo
    playerctl
    swaylock
    swayidle
    brightnessctl
    cliphist
    wlr-randr
  ];
}
