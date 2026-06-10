# Desktop environment base (display server, firmware, power).
{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };

    fwupd.enable = true;
    upower.enable = true;
  };
}
