# System-wide packages: add new entries to environment.systemPackages.
{ pkgs, ... }:
{
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
    opencode
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
    gnome-boxes
    onlyoffice-desktopeditors
    qbittorrent
    rclone
    remmina
    unstablePkgs.github-desktop
    unstablePkgs.pear-desktop
    unstablePkgs.vesktop

    # Communication
    zapzap

    # Media players
    smplayer

    # System utilities
    bleachbit
    dconf-editor
  ];
}
