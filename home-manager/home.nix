# This is your home-manager configuration file.
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
#
# To use, uncomment homeConfigurations in flake.nix.
# Dotfile management is handled separately via GNU stow.
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # inputs.self.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    # ./fish.nix
  ];

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "caio";
    homeDirectory = "/home/caio";
    stateVersion = "25.11";
  };

  # Add stuff for your user as you see fit:
  # programs.home-manager.enable = true;
  # programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  # home.stateVersion = "25.11";
}
