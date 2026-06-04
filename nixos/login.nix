# Display manager, auto-login, and session selection.
{ config, lib, pkgs, ... }: {
  services.displayManager = {
    defaultSession = "gnome";
    autoLogin = {
      enable = true;
      user = "caio";
    };
  };

  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "matrix";
    };
  };
}
