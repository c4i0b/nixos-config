# System-wide packages. Personal packages live in home/caio.nix.
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # --- Spelling / Dictionaries ---
    aspell
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
    aspellDicts.pt_BR

    # --- System Tools ---
    libnotify
    nix-search

    # --- Network ---

    # --- Multimedia ---
  ];
}
