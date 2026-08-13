# Time zone, locale, keyboard and input method.
{ config, pkgs, ... }:
{
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  console.keyMap = "us";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };

  # Cedilla fix (US intl keyboard produces 'ç' instead of 'ć').
  environment.etc."X11/XCompose".text = ''
    include "%L"

    <dead_acute> <c> : "ç" U00E7
    <dead_acute> <C> : "Ç" U00C7
  '';

  environment.sessionVariables = {
    XCOMPOSEFILE = "/etc/X11/XCompose";
  };
}
