# Display manager, auto-login, and session selection.
{ config, lib, pkgs, ... }: {
  services.displayManager = {
    ly = {
      enable = true;
      settings = {
        animation = "matrix";
      };
    };

    defaultSession = "plasma";
    autoLogin = {
      enable = true;
      user = "caio";
    };
  };
}
