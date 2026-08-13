# Bootloader (Limine), kernel and boot visuals.
{ config, pkgs, ... }:
{
  boot.loader.timeout = -1;
  boot.loader.limine.enable = true;
  boot.loader.limine.extraConfig = ''
    quiet: yes
  '';
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.plymouth.enable = true;
  boot.plymouth.theme = "spin";
  boot.plymouth.themePackages = with pkgs; [
    (adi1090x-plymouth-themes.override { selected_themes = [ "spin" ]; })
  ];

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
    "clearcpuid=514"   # Disable UMIP
  ];
}
