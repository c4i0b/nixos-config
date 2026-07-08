# Btrbk — Automated Btrfs Snapshots on NixOS

Source: https://wiki.nixos.org/wiki/Btrbk

Btrbk creates and manages btrfs snapshots with retention policies.

## Local /home Snapshots

Requires `/home` to be its own btrfs subvolume.

```nix
services.btrbk.instances."home" = {
  onCalendar = "hourly";
  settings = {
    snapshot_preserve_min = "1w";
    snapshot_preserve = "2w";
    volume."/" = {
      snapshot_dir = "/snapshots";
      subvolume = "home";
    };
  };
};

# Btrbk does not create snapshot dirs automatically
systemd.tmpfiles.rules = [
  "d /snapshots 0755 root root"
];
```

## Retention policy

```nix
snapshot_preserve    = "7d 4w 12m";  # daily(7d) → weekly(4w) → monthly(12m)
snapshot_preserve_min = "7d";        # keep all snapshots from last 7 days
```

## Remote backup

```nix
services.btrbk.instances."remote" = {
  onCalendar = "weekly";
  settings = {
    ssh_identity = "/etc/btrbk_key";
    ssh_user = "btrbk";
    stream_compress = "lz4";
    volume."/btr_pool" = {
      target = "ssh://myhost/mnt/mybackups";
      subvolume = "nixos";
    };
  };
};
```

## Manual usage

```bash
sudo btrbk -c /etc/btrbk/home.conf --dry-run --progress --verbose run
```
