{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    accela
    btrfs-progs
    curl
    fd
    file
    fzf
    gh
    git
    gdu
    gnumake
    htop
    lazydocker
    lazygit
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
    rsync
    snapper
    stow
    tmux
    topgrade
    tree
    unzip
    usbutils
    uv
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

    # Browsers
    unstablePkgs.brave

    # Desktop
    qbittorrent
    rclone
    unstablePkgs.libreoffice
    remmina

    # Theming
    tela-icon-theme

    # Gaming
    heroic
    protontricks

    # System utilities
    bleachbit
    btrfs-assistant
    dconf-editor
  ];
}
