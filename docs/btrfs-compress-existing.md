# Compress existing data (already-installed system)

Sources:
- Btrfs docs — Defragmentation: https://btrfs.readthedocs.io/en/latest/Defragmentation.html
- Arch Wiki — Btrfs § Compression: https://wiki.archlinux.org/title/Btrfs#Compression
- NixOS Wiki — Btrfs: https://wiki.nixos.org/wiki/Btrfs

## When you need this
Compression was enabled in the config (see ./btrfs.md) and `nixos-rebuild` applied it — but that
only compresses **new** writes. Data written before (the install, old files) is still uncompressed
on disk. Run a one-time defrag to compress what's already there.

## The command
```bash
sudo btrfs filesystem defrag -r -czstd /path
```
- `-r` recursive, `-czstd` compress with zstd (level 3, the default — same as the mount option).
- Safe on a live system.
- Errors on `/proc`, `/sys`, open files, and the read-only `/nix/store` are expected and harmless.

## What to defrag on NixOS
Only `/home` truly needs it — that's where pre-compression user data lives.

- **`/home`** — defrag it (the one-time step below).
- **`/nix`** — **skip it.** `/nix/store` is read-only at runtime (defrag can't touch it), and it
  self-heals: new store paths are born compressed, and `nix.gc` (daily, `--delete-older-than 1d`)
  purges the old uncompressed ones within a few upgrade cycles. No defrag ever needed.
- **`/`** — optional; mostly symlinks into the store, so it's tiny.

## ⚠ Snapshots pin old extents (the usual reason space doesn't drop)
> "Defragmentation does not preserve extent sharing, e.g. files created by **cp --reflink** or
> existing on multiple snapshots. Due to that the data space consumption may increase."
> — btrfs docs

If a subvolume has snapshots (snapper, timeshift…), defrag writes new compressed extents but
the **old ones stay referenced by the snapshots**, so space is NOT freed (and can temporarily rise).
Reclaim it like this (example for `/home` managed by Snapper — see ./snapper.md):

```bash
# 1. stop snapper so it doesn't snapshot mid-defrag
sudo systemctl stop snapper-timeline.timer snapper-cleanup.timer
# 2. delete the snapshots of the subvolume you're defragging
sudo snapper -c home list            # note the last snapshot number N
sudo snapper -c home delete 1-N      # range delete (replace N)
# 3. defrag
sudo btrfs filesystem defrag -r -czstd /home
# 4. restart snapper — new snapshots are of the now-compressed data
sudo systemctl start snapper-timeline.timer snapper-cleanup.timer
```

## Verify
```bash
sudo btrfs filesystem usage /     # watch "Used" / "Data" drop
sudo compsize -x /                # compression ratio per path
df -h /
```

## Notes
- Free space can rise during defrag (new extents written before old are freed) — keep plenty of
  free space; it settles after `sync`.
- This is a **one-time** fix for `/home`. Going forward, the `compress=zstd` mount option handles
  everything; `/nix/store` keeps refreshing compressed on each upgrade. To get compression from
  byte 0 on a fresh install instead, see ./fresh-deploy.md.
