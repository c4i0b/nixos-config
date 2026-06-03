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

  services.displayManager = {
    defaultSession = "niri";
    gdm.enable = true;
    autoLogin = {
      enable = true;
      user = "caio";
    };
  };

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
