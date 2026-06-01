# System packages
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # From stable nixpkgs
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
    nixfmt-rfc-style
    nodejs
    pciutils
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
    zip
    zstd

    # From unstable nixpkgs (actively developed, benefits from latest releases)
    unstablePkgs.bat
    unstablePkgs.btop
    unstablePkgs.eza
    unstablePkgs.fastfetch
    unstablePkgs.opencode
    unstablePkgs.superfile
    unstablePkgs.tealdeer

    # Desktop apps
    brave
    qbittorrent
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
