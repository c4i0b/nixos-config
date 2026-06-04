# Hostname, network manager, and firewall.
{...}: {
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };
}
