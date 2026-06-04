# Hostname, network manager, and firewall.
{...}: {
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = "/var/lib/tailscale/auth.key";
    useRoutingFeatures = "server";
    extraUpFlags = ["--advertise-exit-node" "--accept-dns=false"];
  };
}
