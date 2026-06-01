# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # inputs.self.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      auto-optimise-store = true;
    };
    # Opinionated: disable channels
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
    supportedFilesystems = ["btrfs" "ntfs"];
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

  services = {
    xserver = {
      enable = true;
      xkb.layout = "us";
      videoDrivers = ["nvidia"];
    };

    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
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

    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };

    udev.packages = with pkgs; [steam];
  };

  programs = {
    fish.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extraCompatPackages = [];
    };
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    cascadia-code
  ];

  environment = {
    systemPackages = with pkgs; [
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
    gnome.excludePackages = with pkgs; [
      epiphany
      geary
      totem
      yelp
      simple-scan
      snapshot
    ];
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime.offload.enable = false;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  systemd.services.nvidia-powerd.enable = true;

  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
