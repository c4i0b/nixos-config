# Hostname, network manager, and firewall.
{pkgs, lib, ...}: {
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  systemd.services.NetworkManager-wait-online = {
    enable = true;
    wantedBy = lib.mkForce [];
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "/var/lib/tailscale/auth.key";
  };

  programs.localsend.enable = true;

}
