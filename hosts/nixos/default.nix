{ inputs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/boot.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/localization.nix
    ../../modules/nixos/hardware.nix
    ../../modules/nixos/users.nix
    ../../modules/nixos/systemd.nix
    ../../modules/nixos/programs.nix
    ../../modules/nixos/packages.nix

    # Optional: comment out to disable.
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/services/audio.nix
    ../../modules/nixos/services/flatpak.nix
    ../../modules/nixos/services/snapshots.nix
    ../../modules/nixos/services/virtualisation.nix
    # ../../modules/nixos/services/ssh.nix

    inputs.home-manager.nixosModules.home-manager
  ];

  my.desktop.enable = true;
  # my.services.ssh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup"; # don't fail on pre-existing dotfiles
    users.caio = import ../../home/caio.nix;
  };

  networking.hostName = "nixos";
  system.stateVersion = "26.05";
}
