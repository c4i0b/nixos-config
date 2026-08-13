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
    options = "--delete-older-than 1d";
  };

  nix.optimise.automatic = true;

  # Disabled: with flakes, autoUpgrade pulls the flake dir and switches
  # generation without review. Rebuild manually with `.#nixos`.
  # Local-only re-enable:
  #   system.autoUpgrade = { enable = true; flake = "/etc/nixos#nixos"; flags = [ "--no-update-lock-file" ]; };
  system.autoUpgrade.enable = false;
}
