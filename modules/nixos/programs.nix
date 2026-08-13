{ config, pkgs, ... }:
{
  # fish installed system-wide (login shell); user config lives in Home Manager.
  programs.fish.enable = true;

  programs.steam.enable = true;
  programs.gamemode.enable = true;
}
