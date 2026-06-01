{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      auto-optimise-store = true;
    };
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];
    initrd = {
      systemd.enable = true;
      kernelModules = ["nvme" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    };
    kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
    extraModulePackages = [config.boot.kernelPackages.nvidia_x11];
    supportedFilesystems = ["btrfs" "ntfs"];
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload.enable = false;
      };
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  networking = {
    hostName = "Fedora";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  console.keyMap = "us";

  virtualisation = {
    docker = {
      enable = true;
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
      };
      videoDrivers = ["nvidia"];
    };

    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };

    flatpak.enable = true;
    fwupd.enable = true;

    udev.packages = with pkgs; [steam];
  };

  programs = {
    fish.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = [pkgs.proton-ge-bin];
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  systemd.services.nvidia-powerd.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    cascadia-code
  ];

  environment = {
    systemPackages = with pkgs; [
      bat
      btop
      btrfs-progs
      curl
      eza
      fastfetch
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
      opencode
      pciutils
      ripgrep
      rsync
      snapper
      stow
      superfile
      tealdeer
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

      brave
      qbittorrent
      libreoffice
      remmina

      bleachbit
      btrfs-assistant
      gnome-tweaks
      dconf-editor
    ];

    gnome.excludePackages = with pkgs; [
      epiphany
      geary
      totem
      yelp
      simple-scan
      snapshot
    ];
  };

  users.users.caio = {
    isNormalUser = true;
    description = "Caio";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "docker"
      "libvirtd"
      "kvm"
      "audio"
      "video"
      "input"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII36LvhYgcFFJgpr3/lrnD7z/zp0EKBn2HFUep/0DiEZ"
    ];
  };

  system.stateVersion = "25.11";
}
