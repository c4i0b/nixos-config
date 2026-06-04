# KDE Plasma 6 desktop environment.
{ config, lib, pkgs, ... }: {
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs; [
    kdePackages.khelpcenter
    kdePackages.konqueror
    kdePackages.kmail
    kdePackages.akregator
    kdePackages.korganizer
    kdePackages.kontact
    kdePackages.kaddressbook
    kdePackages.ktnef
    kdePackages.kmahjongg
    kdePackages.kpat
  ];

  environment.systemPackages = with pkgs; [
    ghostty
    numix-icon-theme-circle
    nerd-fonts.caskaydia-cove
    kdePackages.krohnkite
    kdePackages.dynamic-workspaces
  ];

  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass.out}/bin/ksshaskpass";
}
