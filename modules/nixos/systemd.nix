{ config, pkgs, ... }:
{
  systemd.user.services.kaccess.enable = false;
  systemd.user.services.kactivitymanagerd.enable = false;

  systemd.user.services.topgrade-user = {
    description = "Topgrade - user updates";
    path = [ "/run/current-system/sw" ];
    serviceConfig = {
      Type = "oneshot";
      ExecCondition = "${pkgs.iputils}/bin/ping -c 1 -W 5 8.8.8.8";
      ExecStart = "${pkgs.topgrade}/bin/topgrade --disable system --disable firmware --disable nix --yes --no-ask-retry --auto-retry 3 --cleanup";
      Nice = 19;
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
      TimeoutStartSec = "2h";
    };
  };

  systemd.user.timers.topgrade-user = {
    description = "Topgrade - user updates timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1d";
      Persistent = true;
    };
  };
}
