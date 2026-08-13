{ config, pkgs, ... }:
{
  users.users."caio" = {
    isNormalUser = true;
    description = "Caio";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "vboxusers" "podman" ];
    subUidRanges = [{ startUid = 65536; count = 65536; }];
    subGidRanges = [{ startGid = 65536; count = 65536; }];
  };
}
