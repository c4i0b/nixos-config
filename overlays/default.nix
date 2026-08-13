# Overlays; wired in modules/nixos/base.nix.
inputs: final: _prev: {
  # Exposed as `pkgs.unstable` (and `unstable` under `with pkgs;`).
  unstable = import inputs.nixpkgs-unstable {
    system = final.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  # KDE/SDDM from unstable; the stable Plasma/SDDM modules consume these.
  kdePackages = final.unstable.kdePackages;
  sddm = final.unstable.sddm;
}
