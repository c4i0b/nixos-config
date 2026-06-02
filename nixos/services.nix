{pkgs, ...}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      nix-rebuild = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos";
      nix-cleanup = "sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake /etc/nixos";
      nix-generations = "nixos-rebuild list-generations";
      nix-rollback = "sudo nixos-rebuild switch --rollback";
      nix-code = "opencode /etc/nixos";
    };
  };

  systemd.user.services.topgrade = {
    description = "Topgrade";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = "${pkgs.topgrade}/bin/topgrade --disable system";
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
