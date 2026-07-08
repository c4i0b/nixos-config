# Btrfs on NixOS

Source: https://wiki.nixos.org/wiki/Btrfs

## Subvolume management

```bash
# List subvolumes
btrfs subvolume list -t /mnt

# Create subvolume
btrfs subvolume create /mnt/home

# Delete subvolume
btrfs subvolume delete /mnt/home
```

## Compression

Add mount options in hardware-config or fileSystems:

```nix
fileSystems."/" = {
  options = [ "compress=zstd" ];
};
```

Algorithms: `zstd` (best all-round), `lzo` (fast), `zlib` (best ratio, slow).

- New install? Enable compression at mount time → ./fresh-deploy.md
- Existing data (already-installed system)? → ./btrfs-compress-existing.md
  (`btrfs filesystem defrag -r -czstd /path` — note: snapshots pin old extents)

## Auto-scrub (integrity check)

```nix
services.btrfs.autoScrub = {
  enable = true;
  interval = "monthly";
  fileSystems = [ "/" ];
};
```

Check status: `btrfs scrub status /`

## Snapshots

```bash
# Read-only snapshot
btrfs subvolume snapshot -r /home /snapshots/home_$(date +%F)

# Restore
btrfs subvolume delete /home
btrfs subvolume snapshot /snapshots/home_2025-01-01 /home
```
