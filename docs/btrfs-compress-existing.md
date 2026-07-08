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
- Run per subvolume (`/`, `/home`, `/nix`). Safe on a live system.
- Errors on `/proc`, `/sys`, open files, and the read-only `/nix/store` are expected and harmless.

## ⚠ Snapshots pin old extents (the usual reason space doesn't drop)
> "Defragmentation does not preserve extent sharing, e.g. files created by **cp --reflink** or
> existing on multiple snapshots. Due to that the data space consumption may increase."
> — btrfs docs

If a subvolume has snapshots (btrbk, snapper, timeshift…), defrag writes new compressed extents but
the **old ones stay referenced by the snapshots**, so space is NOT freed (and can temporarily rise).
Reclaim it like this (example for `/home` with btrbk):

```bash
# 1. stop the snapshot creator so it doesn't snapshot mid-defrag
sudo systemctl stop btrbk-home.timer btrbk-home.service
# 2. delete the snapshots of the subvolume you're defragging
sudo btrfs subvolume delete /snapshots/home.*
# 3. defrag
sudo btrfs filesystem defrag -r -czstd /home
# 4. restart the creator — new snapshots are of the now-compressed data
sudo systemctl start btrbk-home.timer
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
- `/nix/store` is mounted read-only at runtime, so its files won't defrag in-place. Don't worry:
  store paths written after enabling compression are already compressed, and the store refreshes
  naturally with upgrades.
- This is a **one-time** fix. Going forward, the `compress=zstd` mount option handles everything.
  To get it right at install time instead, see ./fresh-deploy.md.
