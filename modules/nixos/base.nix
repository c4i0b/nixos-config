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

  # Fully autonomous upgrades: pull the latest commit on main AND bump every
  # input to the latest commit on its branch (--override-flake + --refresh) —
  # rolling nixpkgs/home-manager, applied daily. A failed build is safe (the
  # machine keeps its current generation); a build that succeeds but is broken at
  # runtime DOES get applied — roll back to a previous generation (gc keeps 7d).
  # A plain manual rebuild uses the committed flake.lock; to test the latest
  # locally, run `nix flake update` first.
  system.autoUpgrade = {
    enable = true;
    flake = "github:c4i0b/nixos-config/main#nixos";
    flags = [
      "--refresh"
      "--override-flake"
      "nixpkgs"
      "github:NixOS/nixpkgs/nixos-26.05"
      "--override-flake"
      "nixpkgs-unstable"
      "github:NixOS/nixpkgs/nixos-unstable"
      "--override-flake"
      "home-manager"
      "github:nix-community/home-manager/release-26.05"
    ];
    dates = "daily";
    randomizedDelaySec = "45min";
    allowReboot = false;
    persistent = true;
  };
}
