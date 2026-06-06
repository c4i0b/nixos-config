# Gaming: Steam, Proton, and related tooling.
#
# LD_AUDIT injects SLSsteam into Steam for unlocking unowned games.
# SLSsteam config (~/.config/SLSsteam/config.yaml): set PlayNotOwnedGames=yes, NotifyInit=no.
# ACCELA config (~/.config/Tachibana Labs/ACCELA.conf): set sls_config_management=true,
# use_steamless=true. ACCELA manages AdditionalApps in SLSsteam via its API.
#
# Proton compat tools are installed to the Steam library dirs (not managed here).
# Steam auto-selects the default compat tool (proton-cachyos) or per-game overrides.
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
    DXVK_ASYNC = "1";
  };

  services.udev.packages = [steam];

  environment.systemPackages = with pkgs; [
    unstablePkgs.heroic
    unstablePkgs.ludusavi
    unstablePkgs.lutris
    unstablePkgs.protonplus
    unstablePkgs.protontricks
    unstablePkgs.mangojuice
  ];
}
