# Firmware updates and power management.
{ ... }:

{
  services = {
    fwupd.enable = true;
    upower.enable = true;
  };
}
