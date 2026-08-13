# Btrfs snapshots via btrbk (hourly, /home).
{ config, pkgs, ... }:
{
  services.btrbk.instances."home" = {
    onCalendar = "hourly";
    snapshotOnly = true;
    settings = {
      snapshot_preserve_min = "24h";
      snapshot_preserve = "24h";
      volume = {
        "/" = {
          snapshot_dir = "/snapshots";
          subvolume = "home";
        };
      };
    };
  };

  system.activationScripts.btrbk-default-conf = ''
    ln -sfn /etc/btrbk/home.conf /etc/btrbk/btrbk.conf
  '';
}
