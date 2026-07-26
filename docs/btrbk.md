# Btrbk — Btrfs Snapshot Management on NixOS

Sources:
- https://dig.int.ch/btrbk/
- https://wiki.nixos.org/wiki/Btrbk
- https://dataswamp.org/~solene/2022-10-07-nixos-btrfs-continuous-snapshots.html
- Man pages: `btrbk(1)`, `btrbk.conf(5)`
- NixOS module: `nixos/modules/services/backup/btrbk.nix`

Btrbk is a tool for creating local snapshots and remote backups of btrfs
subvolumes. Unlike Snapper, it has built-in `btrfs send/receive` support for
incremental remote backups without external tools.

## Why btrbk over Snapper on NixOS

| Aspect | btrbk | Snapper |
|--------|-------|---------|
| NixOS Wiki page | yes (official) | no |
| `.snapshots` subvolume | NOT required | required (manual creation workaround) |
| Remote backup (send/receive) | built-in | no |
| D-Bus daemon | no (runs as timer) | yes (`snapperd`) |
| GUI | no | btrfs-assistant |
| NixOS module quality | clean, complete | limited (can't create configs via GUI) |
| Rollback at boot | no | yes (with grub-btrfs) |

Snapper works on NixOS but has known pain points:
- Module does NOT create `.snapshots` subvolume (open bug [nixpkgs#213989](https://github.com/NixOS/nixpkgs/issues/213989))
- `TIMELINE_CREATE`/`TIMELINE_CLEANUP` default to `false` (unlike Arch/openSUSE)
- btrfs-assistant GUI can't create snapper configs on NixOS (dev confirmed)

## NixOS configuration

### Local /home snapshots (common case)

```nix
services.btrbk.instances."home" = {
  onCalendar = "hourly";
  settings = {
    snapshot_preserve_min = "1w";
    snapshot_preserve = "2w";
    volume = {
      "/" = {
        snapshot_dir = "/snapshots";
        subvolume = "home";
      };
    };
  };
};

systemd.tmpfiles.rules = [
  "d /snapshots 0755 root root"
];
```

Snapshot dir must be created via tmpfiles or manually — btrbk does NOT create
it automatically.

### Remote backup via SSH

Requires the root btrfs device mounted at a known path (subvolid=5):

```nix
fileSystems."/btr_pool" = {
  device = "/dev/disk/by-uuid/08334927-...";
  fsType = "btrfs";
  options = [ "subvolid=5" ];
};

services.btrbk.instances."remote_backup" = {
  onCalendar = "weekly";
  settings = {
    ssh_identity = "/etc/btrbk_key";
    ssh_user = "btrbk";
    stream_compress = "lz4";
    volume."/btr_pool" = {
      target = "ssh://myhost/mnt/mybackups";
      subvolume = "home";
    };
  };
};
```

## Retention policy

Btrbk uses two retention options:

- `snapshot_preserve_min` — minimum time to keep ALL snapshots (safety net)
- `snapshot_preserve` — graduated retention after `preserve_min` expires

### Example: 2-week window with daily granularity

```nix
settings = {
  snapshot_preserve_min = "1w";   # keep all snapshots from last 7 days
  snapshot_preserve = "2w";       # after 1 week, keep 1/day for 2nd week
};
```

### Example: graduated retention (daily → weekly → monthly)

```nix
settings = {
  snapshot_preserve_min = "7d";   # all dailies from last week
  snapshot_preserve = "7d 4w 12m"; # then weekly for 1 month, monthly for 1 year
};
```

## CLI

```bash
# Dry run (test config without making changes)
btrbk -c /etc/btrbk/home.conf --dry-run --verbose run

# List snapshots
btrbk -c /etc/btrbk/home.conf list

# Create snapshot now
btrbk -c /etc/btrbk/home.conf snapshot

# Delete specific snapshot
btrbk -c /etc/btrbk/home.conf delete snapshot <snapshot_id>

# Restore: delete current subvolume, replace with snapshot
btrfs subvolume delete /home
btrfs subvolume snapshot /snapshots/<snapshot_id>/snapshot /home
```

## Migration from Snapper

### 1. Delete all Snapper snapshots

```bash
# List all snapshots
snapper -c home list

# Delete all
snapper -c home delete --all
```

### 2. Remove Snapper config from configuration.nix

Remove or comment out:
```nix
# Remove these blocks:
services.snapper.configs."home" = { ... };
system.activationScripts.snapper-home = ...;
```

Also remove `btrfs-assistant` from `environment.systemPackages` if no longer needed.

### 3. Add btrbk configuration

See "Local /home snapshots" section above.

### 4. Rebuild

```bash
sudo nixos-rebuild switch
```

### 5. Verify

```bash
btrbk -c /etc/btrbk/home.conf --dry-run --verbose run
btrbk -c /etc/btrbk/home.conf snapshot
btrbk -c /etc/btrbk/home.conf list
```

## Filesystem layout

Btrbk stores snapshots in `<snapshot_dir>/<subvol_name>.<timestamp>`.
Unlike Snapper, `.snapshots` subvolume is NOT required — btrbk creates
regular directories under `snapshot_dir`.

### Subvolume considerations

- `/nix` should NOT be snapshotted (separate subvolume, Nix manages its own GC)
- `/home` is the primary target for user data snapshots
- Snapshots of `/` are optional (root is mostly declarative via NixOS config)
