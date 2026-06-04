# Gaming: Steam, Proton, and related tooling.
{pkgs, ...}: let
  # SLSsteam injected via LD_AUDIT into Steam's FHS env.
  # Post-install: edit ~/.config/SLSsteam/config.yaml to set:
  #   PlayNotOwnedGames, SafeMode
  # ACCELA config at ~/.config/Tachibana\ Labs/ACCELA.conf needs:
  #   library_mode=true, use_steamless=true, slssteam_mode=true
  sls-steam-libs = "${pkgs.sls-steam}/library-inject.so:${pkgs.sls-steam}/SLSsteam.so";
in {
  programs.steam = {
    enable = true;
    package = pkgs.unstablePkgs.steam.override {
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

  services.udev.packages = [pkgs.unstablePkgs.steam];
}
