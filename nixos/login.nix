# Display manager, auto-login, and session selection.
{ config, lib, pkgs, ... }: {
  services.displayManager = {
    ly = {
      enable = true;
      settings = {
        animation = "matrix";
        session_log = null;
      };
    };

    defaultSession = "plasma";
    autoLogin = {
      enable = true;
      user = "caio";
    };
  };
}
