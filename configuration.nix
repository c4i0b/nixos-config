{ config, pkgs, ... }:

let
  # Unstable channel
  unstable = import <nixos-unstable/nixpkgs> { config = { allowUnfree = true; }; };
in

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ============================================================================
  # 1. Boot & Kernel
  # ============================================================================
  boot.loader.timeout = -1;
  boot.loader.limine.enable = true;
  boot.loader.limine.extraConfig = ''
    quiet: yes
  '';
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = unstable.linuxPackages_latest;

  boot.plymouth.enable = true;
  boot.plymouth.theme = "spin";
  boot.plymouth.themePackages = with pkgs; [
    (adi1090x-plymouth-themes.override { selected_themes = [ "spin" ]; })
  ];

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "rd.udev.log_level=3"
    "rd.systemd.show_status=auto"
    "clearcpuid=514"   # Disable UMIP
  ];

  # ============================================================================
  # 2. Networking
  # ============================================================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # ============================================================================
  # 3. Localization
  # ============================================================================
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  console.keyMap = "us";

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
  };

  # Cedilla fix
  environment.etc."X11/XCompose".text = ''
    include "%L"

    <dead_acute> <c> : "ç" U00E7
    <dead_acute> <C> : "Ç" U00C7
  '';

  environment.sessionVariables = {
    XCOMPOSEFILE = "/etc/X11/XCompose";
  };

  # ============================================================================
  # 4. Display & Desktop
  # ============================================================================
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "caio";
  services.desktopManager.plasma6.enable = true;

  # Exclude xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Minimal KDE
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
    plasma-browser-integration
    elisa
    gwenview
    okular
    kate
    khelpcenter
    kwalletmanager
    filelight
    krdc
    krfb
    spectacle
  ];
  # services.xserver.libinput.enable = true;

  # -- Fonts --
  fonts.packages = with pkgs; [
    inter
    cascadia-code
  ];

  # ============================================================================
  # 5. Hardware
  # ============================================================================

  # -- NVIDIA --
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = true;
    open = true;
    branch = "latest";
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.extraModprobeConfig = ''
    # Disable HDA Intel power saving (idle audio pops)
    options snd_hda_intel power_save=0 power_save_controller=N
  '';

  # -- Storage --
  fileSystems."/mnt/KingFast_EXT4" = {
    device = "/dev/disk/by-label/KingFast_EXT4";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  # -- Btrfs compression (zstd) --
  fileSystems."/".options = [ "compress=zstd" "noatime" ];
  fileSystems."/home".options = [ "subvol=home" "compress=zstd" "noatime" ];
  fileSystems."/nix".options = [ "subvol=nix" "compress=zstd" "noatime" ];

  # -- Zram swap --
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # -- Btrfs --
  services.btrfs.autoScrub.enable = true;

  # -- Bluetooth --
  hardware.bluetooth.enable = true;
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="a728", ATTR{power/control}="on"
  '';

  # ============================================================================
  # 6. Users
  # ============================================================================
  users.users."caio" = {
    isNormalUser = true;
    description = "Caio";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "vboxusers" "podman" ];
    subUidRanges = [{ startUid = 65536; count = 65536; }];
    subGidRanges = [{ startGid = 65536; count = 65536; }];
  };

  # ============================================================================
  # 7. Security & Package Overrides
  # ============================================================================
  nixpkgs.config.allowUnfree = true;

  # KDE unstable (overlay plasma6 module + KDE apps onto unstable)
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = unstable.kdePackages;
    })
  ];

  # ============================================================================
  # 8. Services
  # ============================================================================

  # -- Printing --
  # services.printing.enable = true;

  # -- PipeWire --
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # -- Flatpak --
  services.flatpak.enable = true;
  system.activationScripts.flathub = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  '';

  # -- Btrfs snapshots (Snapper) --
  services.snapper.configs."home" = {
    SUBVOLUME = "/home";
    TIMELINE_CREATE = true;
    TIMELINE_CLEANUP = true;
    TIMELINE_LIMIT_HOURLY = "24";
    TIMELINE_LIMIT_DAILY = "7";
    TIMELINE_LIMIT_WEEKLY = "0";
    TIMELINE_LIMIT_MONTHLY = "0";
    TIMELINE_LIMIT_YEARLY = "0";
  };
  system.activationScripts.snapper-home = ''
    ${pkgs.btrfs-progs}/bin/btrfs subvolume show /home/.snapshots >/dev/null 2>&1 \
      || ${pkgs.btrfs-progs}/bin/btrfs subvolume create /home/.snapshots
    chmod 750 /home/.snapshots
  '';

  # -- VirtualBox --
  virtualisation.virtualbox.host.enable = true;
  environment.variables.VBOX_DISABLE_HARDENING = "1";

  # ============================================================================
  # 9. Programs (enabled via NixOS modules)
  # ============================================================================
  programs.fish.enable = true;
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # ============================================================================
  # 10. Virtualization
  # ============================================================================
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ============================================================================
  # 11. Systemd
  # ============================================================================

  # -- User services (topgrade) --
  systemd.user.services.topgrade-user = {
    description = "Topgrade - user updates";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.topgrade}/bin/topgrade --disable system --disable firmware --yes --no-ask-retry --auto-retry 3";
      Nice = 19;
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
      TimeoutStartSec = "2h";
    };
  };

  systemd.user.timers.topgrade-user = {
    description = "Topgrade - user updates timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      RandomizedDelaySec = "30min";
      Persistent = true;
    };
  };

  # ============================================================================
  # 12. System Packages (organized by category)
  #    Stable packages in main list, unstable packages in ++ block
  # ============================================================================
  environment.systemPackages = with pkgs; [
    # --- Spelling / Dictionaries ---
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.pt_BR

    # --- GUI Apps ---
    (kdePackages.spectacle.override {
      tesseractLanguages = [ "eng" "por" ];
    })
  ] ++ (with unstable; [
    # --- Development ---
    gh
    git
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
    nix-search

    # --- System Tools ---
    gdu
    jq
    libnotify
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
    btrfs-assistant
    # --- Gaming ---
    ludusavi
    lutris
    mangohud
    goverlay
    wine
    winetricks

    # --- Network ---

    # --- Multimedia ---
    pear-desktop
  ]);

  # ============================================================================
  # 13. System State & Maintenance
  # ============================================================================
  system.stateVersion = "26.05";

  system.autoUpgrade = {
    enable = true;
    dates = "02:00";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 1d";
  };

  nix.optimise.automatic = true;
}
