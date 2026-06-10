# Fonts, GTK themes, and icons.
{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    source-sans
    inter
  ];

  environment.systemPackages = with pkgs; [
    adw-gtk3
    numix-icon-theme-circle
  ];

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=adw-gtk3-dark
  '';

  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-application-prefer-dark-theme=1
    gtk-theme-name=adw-gtk3-dark
  '';
}
