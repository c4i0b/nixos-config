# System-wide packages: add new entries to environment.systemPackages.
{ pkgs, ... }:
{
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [

    # Development
    accela
    git
    gh
    gnumake
    nil
    nodejs
    python3

    # CLI tools
    bat
    btop
    curl
    eza
    fd
    file
    fzf
    gdu
    jq
    mtr
    ncdu
    proton-vpn-cli
    ripgrep
    rsync
    tealdeer
    topgrade
    tree
    uv
    wget
    zip
    unzip
    zstd

    # Terminal
    fastfetch
    lazygit
    nix-index
    nix-search
    nixfmt
    unstablePkgs.opencode
    superfile
    television
    tmux
    stow

    # Filesystems and disks
    btrfs-progs
    snapper

    # Hardware
    ddcutil
    pciutils
    usbutils

    # Clipboard
    xclip
    wl-clipboard
    xcb-util-cursor

    # Browsers
    unstablePkgs.brave

    # Editors
    unstablePkgs.vscodium

    # Desktop
    file-roller
    gearlever
    gnome-boxes
    onlyoffice-desktopeditors
    qbittorrent
    rclone
    remmina
    unstablePkgs.pear-desktop
    unstablePkgs.vesktop

    # Communication
    zapzap

    # Media players
    mpc-qt

    # System utilities
    bleachbit
    dconf-editor
    gnome-calculator
    gnome-disk-utility
  ];
}
