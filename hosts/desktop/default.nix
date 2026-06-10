# Host-specific: desktop peripherals and mounts.
{ pkgs, ... }:

{
  fileSystems."/mnt/KingFast_EXT4" = {
    device = "/dev/disk/by-uuid/fcffc74c-886d-41f1-bf7c-af282f82b14c";
    fsType = "ext4";
  };

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/90-audio-disable.conf" ''
      monitor.alsa.rules = [
        {
          matches = [ { device.vendor.id = "~0x10de.*" } ]
          actions = { update-props = { device.disabled = true } }
        }
        {
          matches = [ { device.name = "~.*MCHOSE_X9.*" } ]
          actions = { update-props = { device.profile-set = "analog-only.conf" } }
        }
      ]
    '')
  ];
}
