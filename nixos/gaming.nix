{pkgs, ...}: {
  programs = {
    steam = {
      enable = true;
      package = pkgs.unstablePkgs.steam;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = [];
    };
  };

  services.udev.packages = [pkgs.unstablePkgs.steam];
}
