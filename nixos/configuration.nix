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

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix

    # Split configuration modules
    ./login.nix
    ./boot.nix
    ./gpu.nix
    ./networking.nix
    ./users.nix
    ./desktop.nix
    ./input.nix
    # ./gnome.nix
    ./cinnamon.nix
    # ./niri.nixos
    # ./noctalia.nix
    # ./kde.nix
    ./snapper.nix
    ./services.nix
    ./shell.nix
    ./gaming.nix
    #./streaming.nix
    ./virtualisation.nix
    ./packages.nix
    ./browser-policies.nix
  ];

  fileSystems."/mnt/KingFast_EXT4" = {
    device = "/dev/disk/by-uuid/fcffc74c-886d-41f1-bf7c-af282f82b14c";
    fsType = "ext4";
  };

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
      dates = "daily";
      randomizedDelaySec = "1h";
      options = "--delete-older-than 7d";
    };
  };

  systemd.services.nix-gc.serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:c4i0b/nixos-config";
    randomizedDelaySec = "1h";
    dates = "daily";
  };

  systemd.services.nixos-upgrade.serviceConfig = {
    Restart = "on-failure";
    RestartSec = "2h";
    Nice = 19;
    IOSchedulingClass = "idle";
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

  environment.sessionVariables = {
    XCOMPOSEFILE = "/etc/XCompose";
  };

  environment.etc."XCompose".text = ''
    include "%L"
    <dead_acute> <C> : "Ç"
    <dead_acute> <c> : "ç"
  '';

  console.keyMap = "us-acentos";

  services.xserver.xkb = {
    layout = "us";
    variant = "intl";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
