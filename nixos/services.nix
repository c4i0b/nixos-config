# System services, shell, and user timer units.
{pkgs, ...}: {
  programs.fish = {
    enable = true;
    shellAliases = {
      nix-rebuild = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos";
      nix-cleanup = "sudo nix-collect-garbage -d && sudo nixos-rebuild boot --flake /etc/nixos";
      nix-gens = "nixos-rebuild list-generations";
      nix-rollback = "sudo nixos-rebuild switch --rollback";
      nix-code = "opencode /etc/nixos";
      snap-list = "sudo snapper -c home list";
      snap-status = "sudo snapper -c home status";
      snap-diff = "sudo snapper -c home diff";
      snap-delete = "sudo snapper -c home delete";
    };

  };

  environment.etc = {
    "fish/functions/snap-create.fish".text = ''
      function snap-create --description "Create a snapper snapshot"
        set -l desc $argv[1]
        if test -z "$desc"
          set desc (date "+%Y-%m-%d_%H:%M:%S")
        end
        sudo snapper -c home create --description "$desc"
      end
    '';

    "fish/functions/snap-undo.fish".text = ''
      function snap-undo --description "Revert file changes from a snapshot"
        if test (count $argv) -eq 0
          echo "Usage: snap-undo <snapshot_number>"
          return 1
        end
        sudo snapper -c home undochange $argv[1]
      end
    '';
  };

  systemd.user.services.topgrade = {
    description = "Topgrade";
    serviceConfig = {
      Type = "oneshot";
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      ${pkgs.topgrade}/bin/topgrade --disable system || notify-send -u critical "Topgrade" "Update failed — check journalctl --user -u topgrade"
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
