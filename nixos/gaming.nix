# Gaming: Steam, Proton, and related tooling.
{pkgs, ...}: let
  steam = pkgs.unstablePkgs.steam;
  sls-steam-libs = "${pkgs.sls-steam}/library-inject.so:${pkgs.sls-steam}/SLSsteam.so";
in {
  programs.steam = {
    enable = true;
    package = steam.override {
      extraEnv = { LD_AUDIT = sls-steam-libs; };
    };
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ ];
  };

  environment.sessionVariables = {
    PROTON_ENABLE_NVAPI = "1";
    PROTON_DLSS_UPGRADE = "1";
    PROTON_ENABLE_WAYLAND = "1";
    DXVK_ASYNC = "1";
  };

  services.udev.packages = [steam];
}
