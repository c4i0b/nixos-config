# Plasma 6 + SDDM. Enable via `my.desktop.enable` in the host.
{ lib, config, pkgs, ... }:
let
  cfg = config.my.desktop;
in
{
  options.my.desktop.enable = lib.mkEnableOption "desktop environment";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "caio";
    services.desktopManager.plasma6.enable = true;

    services.xserver.excludePackages = [ pkgs.xterm ];

    environment.plasma6.excludePackages = with pkgs.kdePackages; [
      discover
      plasma-browser-integration
      elisa
      gwenview
      okular
      kate
      khelpcenter
      kwalletmanager
      filelight
      krdc
      krfb
      spectacle
    ];

    fonts.packages = with pkgs; [
      inter
      cascadia-code
    ];
  };
}
