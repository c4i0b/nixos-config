{ lib, pkgs, ... }:
let
  mergedGsettings = pkgs.symlinkJoin {
    name = "merged-gsettings-overrides";
    paths = [
      pkgs.gnome.nixos-gsettings-overrides
      pkgs.cinnamon-gsettings-overrides
    ];
  };
in {
  services.xserver.desktopManager.cinnamon.enable = true;

  environment.cinnamon.excludePackages = with pkgs; [
    celluloid
  ];

  environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = lib.mkForce "${mergedGsettings}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
}
