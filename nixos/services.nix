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

  systemd.user.services.rclone-bisync = {
    description = "rclone bisync OneDrive:Sync ↔ ~/Documents/Rclone";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      ${pkgs.rclone}/bin/rclone bisync \
        OneDrive:Sync "$HOME/Documents/Rclone" \
        --create-empty-src-dirs \
        --compare size,modtime,checksum \
        --verbose \
        --log-file "$HOME/.local/share/rclone/bisync.log"
    '';
  };

  systemd.user.timers.rclone-bisync = {
    description = "Daily rclone bisync";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
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

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
