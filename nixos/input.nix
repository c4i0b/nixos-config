{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.settings.addons = {
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
}
