{ config, lib, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.unstablePkgs.noctalia-shell ];
}
