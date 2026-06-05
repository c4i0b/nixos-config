# System services and user timer units.
{pkgs, ...}: {
  systemd.user.services.topgrade = {
    description = "Topgrade";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      ${pkgs.topgrade}/bin/topgrade --disable system
    '';
  };

  systemd.user.timers.topgrade = {
    description = "Daily topgrade";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
