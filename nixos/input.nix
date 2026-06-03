{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.settings = {
      inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us(intl)";
          DefaultIM = "keyboard-us-intl";
        };
        "Groups/0/Items/0" = {
          Name = "keyboard-us-intl";
          Layout = "";
        };
        GroupOrder = {
          "0" = "Default";
        };
      };
      addons = {
        notificationitem = {
          globalSection.Enabled = "False";
        };
        wayland = {
          globalSection.AllowOverridingSystemXKBSettings = "False";
        };
        xcb = {
          globalSection.AllowOverridingSystemXKBSettings = "False";
        };
      };
    };
  };
}
