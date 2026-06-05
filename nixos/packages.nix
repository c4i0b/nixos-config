# System-wide packages: add new entries to environment.systemPackages.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    accela
    btrfs-progs
    curl
    fd
    file
    fzf
    git
    gdu
    gh
    gnumake
    mtr
    ncdu
    nil
    nix-index
    nix-search
    nixfmt
    nodejs
    pciutils
    python3
    ripgrep
    jq
    rsync
    snapper
    stow
    tmux
    topgrade
    tree
    unzip
    usbutils
    wget
    wl-clipboard
    xcb-util-cursor
    zip
    zstd

    # Actively developed (unstable for latest releases)
    unstablePkgs.bat
    unstablePkgs.btop
    unstablePkgs.eza
    unstablePkgs.fastfetch
    unstablePkgs.opencode
    unstablePkgs.superfile
    unstablePkgs.tealdeer
    unstablePkgs.television

    unstablePkgs.lazygit
    unstablePkgs.uv

    # Browsers
    unstablePkgs.brave

    # Editors
    unstablePkgs.vscodium

    # Desktop
    file-roller
    github-desktop
    gnome-boxes
    qbittorrent
    rclone
    onlyoffice-desktopeditors
    remmina
    unstablePkgs.vesktop
    unstablePkgs.pear-desktop

    # Theming
    numix-icon-theme-circle

    # Communication
    zapzap

    # Gaming
    heroic
    ludusavi
    protontricks

    # Media players
    smplayer

    # System utilities
    bleachbit
    dconf-editor
    ddcutil
  ];
}
