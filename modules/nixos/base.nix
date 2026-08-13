{ inputs, lib, pkgs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Resolve the `nix` CLI to the flake-pinned nixpkgs, not whatever channel is present.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ ((import ../../overlays) inputs) ];

  nix.gc = {
    automatic = true;
    dates = "daily";
    randomizedDelaySec = "45min";
    options = "--delete-older-than 7d";
  };

  nix.optimise.automatic = true;

  # Auto-apply the latest commit on main from GitHub on every machine.
  # --refresh re-resolves main each run; locked inputs (nixpkgs) stay pinned.
  # A failed build is safe (the machine keeps its current generation). A build
  # that succeeds but is broken at runtime DOES get applied — roll back to a
  # previous generation (gc keeps 7d so rollback targets survive).
  system.autoUpgrade = {
    enable = true;
    flake = "github:c4i0b/nixos-config/main#nixos";
    flags = [ "--refresh" ];
    dates = "daily";
    randomizedDelaySec = "45min";
    allowReboot = false;
    persistent = true;
  };
}
