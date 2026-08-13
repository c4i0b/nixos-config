# Home Manager config for "caio".
{ pkgs, ... }:
{
  imports = [
    ../modules/home-manager/base.nix
    ../modules/home-manager/shell.nix
    ../modules/home-manager/git.nix
    # ../modules/home-manager/programs/neovim.nix
  ];

  home.username = "caio";
  home.homeDirectory = "/home/caio";
  home.stateVersion = "26.05";

  # All from nixpkgs-unstable (see overlays/default.nix); system core stays stable.
  home.packages = with pkgs.unstable; [
    # --- Development ---
    gh
    nodejs
    opencode
    python3
    uv

    # --- CLI ---
    bat
    btop
    eza
    fastfetch
    fd
    fzf
    lazygit
    micro
    superfile
    taskwarrior3
    tealdeer
    television
    topgrade

    # --- System Tools ---
    gdu
    jq
    unzip

    # --- Containers ---
    distrobox
    oxker
    podman-compose
    podman-tui

    # --- Fun ---
    unimatrix

    # --- GUI Apps ---
    gnome-disk-utility
    (kdePackages.spectacle.override {
      tesseractLanguages = [ "eng" "por" ];
    })
    pear-desktop

    # --- Gaming ---
    ludusavi
    faugus-launcher
    mangohud
    goverlay
    wine
    winetricks

    # --- Network ---

    # --- Multimedia ---
  ];
}
