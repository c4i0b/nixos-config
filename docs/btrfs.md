# Btrfs on NixOS

Sources:
- https://wiki.nixos.org/wiki/Btrfs
- https://btrfs.readthedocs.io/en/latest/btrfs-man5.html (mount options)

## Mount options

Recommended `fileSystems.*.options` for btrfs on NixOS:

```nix
fileSystems."/".options     = [ "compress=zstd" "noatime" ];
fileSystems."/home".options = [ "subvol=home" "compress=zstd" "noatime" ];
fileSystems."/nix".options  = [ "subvol=nix"  "compress=zstd" "noatime" ];
```

| Option | Status | Why |
|--------|--------|-----|
| `compress=zstd` | **set it** | Transparent compression; new writes only — see ./btrfs-compress-existing.md |
| `noatime` | **set it** | Stops access-time updates on every read. Critical with snapshots: `relatime` + freshly-snapshotted old files triggers COW writes *per file* (btrfs(5)). |
| `ssd` | auto | Detected for non-rotational devices; no need to set |
| `discard=async` | auto | Default since kernel 6.2 when device supports TRIM |
| `space_cache=v2` | auto | Default free-space tree |

Avoid: `nodatacow`/`nodatasum` (disables compression + checksums), `commit=N>30`
(crash risk), `ssd_spread` (layout tuning dropped in 4.14, no modern benefit).

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

Automated snapshots are managed by Snapper (see ./snapper.md). Manual raw commands:

```bash
# Read-only snapshot
btrfs subvolume snapshot -r /home /tmp/home_$(date +%F)

# Restore
btrfs subvolume delete /home
btrfs subvolume snapshot /tmp/home_2025-01-01 /home
```
