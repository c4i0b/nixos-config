{ config, lib, pkgs, ... }: {
  services.displayManager = {
    gdm.enable = true;
    autoLogin = {
      enable = true;
      user = "caio";
    };
    defaultSession = "gnome";
  };
}
