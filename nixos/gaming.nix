{pkgs, ...}: {
  programs.steam = {
    enable = true;
    package = pkgs.unstablePkgs.steam;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [];
  };

  services.udev.packages = [pkgs.unstablePkgs.steam];

  environment.sessionVariables = {
    PROTON_ENABLE_NVAPI = "1";
    PROTON_DLSS_UPGRADE = "1";
    PROTON_ENABLE_WAYLAND = "1";
    DXVK_ASYNC = "1";
  };
}
