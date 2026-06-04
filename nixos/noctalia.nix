# Noctalia desktop shell.
{ config, lib, pkgs, ... }:
let
  noctaliaPkg = pkgs.unstablePkgs.noctalia-shell;
in {
  environment.systemPackages = [ noctaliaPkg ];
}
