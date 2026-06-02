{...}: {
  networking = {
    hostName = "Fedora";
    networkmanager.enable = true;
    firewall.enable = true;
  };
}
