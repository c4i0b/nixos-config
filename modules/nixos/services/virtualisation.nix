# VirtualBox host + Podman (dockerCompat).
{ config, pkgs, ... }:
{
  virtualisation.virtualbox.host.enable = true;
  environment.variables.VBOX_DISABLE_HARDENING = "1";

  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
}
