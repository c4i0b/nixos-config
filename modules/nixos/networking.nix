{ config, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.modemmanager.enable = false;
}
