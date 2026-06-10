# Display manager, auto-login, session selection, display server, and input methods.
{ config, lib, pkgs, ... }:
{
  services = {
    displayManager = {
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

    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      xkb = {
        layout = "us";
        variant = "intl";
      };
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = [ ];
    fcitx5.waylandFrontend = true;
    fcitx5.settings.globalOptions = {
      "Behavior/DisabledAddons" = {
        "0" = "notificationitem";
        "1" = "classicui";
      };
    };
  };
}
