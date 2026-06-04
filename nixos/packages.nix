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
    lazydocker
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

    # Browsers
    unstablePkgs.brave

    # Desktop
    file-roller
    gnome-boxes
    qbittorrent
    rclone
    unstablePkgs.libreoffice
    remmina
    unstablePkgs.vesktop
    unstablePkgs.pear-desktop
    winboat

    # Theming
    numix-icon-theme-circle

    # Communication
    zapzap

    # Gaming
    heroic
    ludusavi
    protontricks

    # System utilities
    bleachbit
    btrfs-assistant
    dconf-editor
    ddcutil
  ];
}
