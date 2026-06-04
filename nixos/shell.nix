# Fish shell: aliases, functions, and configuration.
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
}
