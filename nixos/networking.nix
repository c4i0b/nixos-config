# Hostname, network manager, and firewall.
{...}: {
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services.tailscale = {
    enable = true;
    authKeyFile = "/var/lib/tailscale/auth.key";
  };
}
