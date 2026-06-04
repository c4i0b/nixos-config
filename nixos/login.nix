# Display manager, auto-login, and session selection.
{ config, lib, pkgs, ... }: {
  services.displayManager = {
    ly = {
      enable = true;
      settings = {
        animation = "matrix";
        ly_log = null;
        session_log = null;
      };
    };

    defaultSession = "gnome";
    autoLogin = {
      enable = true;
      user = "caio";
    };
  };
}
