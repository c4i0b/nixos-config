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
    gnumake
    htop
    lazydocker
    lazygit
    mtr
    ncdu
    nil
    nix-index
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

    unstablePkgs.bat
    unstablePkgs.btop
    unstablePkgs.eza
    unstablePkgs.fastfetch
    unstablePkgs.opencode
    unstablePkgs.superfile
    unstablePkgs.tealdeer

    brave
    qbittorrent
    rclone
    libreoffice
    remmina

    protontricks
    protonplus

    bleachbit
    btrfs-assistant
    gnome-extensions-cli
    gnome-tweaks
    dconf-editor
  ];
}
