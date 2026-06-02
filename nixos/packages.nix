{pkgs, ...}: let
  u = pkgs.unstablePkgs;
  s = pkgs;
in {
  environment.systemPackages = [
    pkgs.accela

    # Default: unstable
    u.bat
    u.btop
    u.eza
    u.fastfetch
    u.opencode
    u.superfile
    u.tealdeer

    u.btrfs-progs
    u.curl
    u.fd
    u.file
    u.fzf
    u.git
    u.gdu
    u.gnumake
    u.htop
    u.lazydocker
    u.lazygit
    u.mtr
    u.ncdu
    u.nil
    u.nix-index
    u.nixfmt
    u.nodejs
    u.pciutils
    u.python3
    u.ripgrep
    u.rsync
    u.snapper
    u.stow
    u.tmux
    u.topgrade
    u.tree
    u.unzip
    u.usbutils
    u.uv
    u.wget
    u.wl-clipboard
    u.xcb-util-cursor
    u.zip
    u.zstd

    u.bleachbit
    u.btrfs-assistant
    u.gnome-extensions-cli
    u.gnome-tweaks
    u.dconf-editor

    u.brave
    u.qbittorrent
    u.rclone

    # Stable: critical desktop apps
    s.libreoffice
    s.remmina
    s.protontricks
    s.protonplus
  ];
}
