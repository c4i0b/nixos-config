# Snapper — Btrfs Snapshot Management on NixOS

Sources:
- https://wiki.archlinux.org/title/Snapper
- https://en.opensuse.org/Portal:Snapper
- SUSE admin guide: https://documentation.suse.com/sles/15-SP5/html/SLES-all/cha-snapper.html
- Man pages: `snapper(8)`, `snapper-configs(5)`
- NixOS module: `nixos/modules/services/misc/snapper.nix`

Snapper is a tool by openSUSE (Arvin Schnell) for managing btrfs subvolume snapshots.
It supports timeline (hourly/daily/weekly/monthly/yearly) snapshots, pre/post
snapshots around changes, boot snapshots, file-level restore and system rollback.

> Unlike btrbk, Snapper has **no built-in send/receive backup** to remote targets.
> It only does local snapshots. For off-host backups, pair it with `btrbk`,
> `bees`, or manual `btrfs send/receive`.

## NixOS module

The NixOS `services.snapper` module writes `/etc/snapper/configs/<name>` from the
declarative config and ships two systemd timers:

- `snapper-timeline.timer` → `OnCalendar = snapshotInterval` (default `hourly`)
  Creates timeline snapshots.
- `snapper-cleanup.timer` → `OnBootSec=10m`, `OnUnitActiveSec=cleanupInterval`
  (default `1d`) Runs the cleanup algorithm.

Both timers are enabled automatically when `configs != {}`.

### Minimal /home config

Requires `/home` to be its own btrfs subvolume.

```nix
services.snapper.configs."home" = {
  SUBVOLUME = "/home";
  FSTYPE = "btrfs";
  TIMELINE_CREATE = true;   # take hourly snapshots
  TIMELINE_CLEANUP = true;  # enable the timeline cleanup algorithm
};
```

The NixOS module writes `/etc/snapper/configs/<name>` but does **not** create the
`.snapshots` subvolume. Snapper requires it to be a real btrfs subvolume (a plain
directory triggers an IO Error). Create it idempotently via an activation script:
```nix
system.activationScripts.snapper-home = ''
  ${pkgs.btrfs-progs}/bin/btrfs subvolume show /home/.snapshots >/dev/null 2>&1 \
    || ${pkgs.btrfs-progs}/bin/btrfs subvolume create /home/.snapshots
'';
```
It must be owned by root (default when created as root). NixOS has no native
declarative subvolume creation; `disko` is the alternative for full layout management.

### Global options

```nix
services.snapper = {
  snapshotInterval = "hourly";  # OnCalendar for snapper-timeline.timer
  cleanupInterval = "1d";       # OnUnitActiveSec for snapper-cleanup.timer
  persistentTimer = false;      # catch up missed runs while powered off
  snapshotRootOnBoot = false;   # snapshot "root" config on every boot
  filters = null;               # global diff filter (see snapper-configs(5))
};
```

## Retention policy (TIMELINE limits)

Timeline cleanup keeps the N most-recent snapshots per granularity. Each limit
is **independent** (a snapshot may count as both hourly and daily).

| Option (in config)         | Default | Meaning                          |
|----------------------------|---------|----------------------------------|
| `TIMELINE_CREATE`          | `no`    | Create a snapshot every interval |
| `TIMELINE_CLEANUP`         | `no`    | Run timeline cleanup             |
| `TIMELINE_MIN_AGE`         | `1800`  | Don't delete snapshots < 30 min  |
| `TIMELINE_LIMIT_HOURLY`    | `10`    | Keep last N hourly               |
| `TIMELINE_LIMIT_DAILY`     | `10`    | Keep last N daily (first of day) |
| `TIMELINE_LIMIT_WEEKLY`    | `0`     | Keep last N weekly               |
| `TIMELINE_LIMIT_MONTHLY`   | `10`    | Keep last N monthly              |
| `TIMELINE_LIMIT_QUARTERLY` | `0`     | Keep last N quarterly            |
| `TIMELINE_LIMIT_YEARLY`    | `10`    | Keep last N yearly               |

### Example: 1-week window, hourly granularity for the last day

```nix
services.snapper.configs."home" = {
  SUBVOLUME = "/home";
  TIMELINE_CREATE = true;
  TIMELINE_CLEANUP = true;
  TIMELINE_LIMIT_HOURLY = "24";  # last 24 hours, hourly
  TIMELINE_LIMIT_DAILY  = "7";   # last 7 days, 1/day
  TIMELINE_LIMIT_WEEKLY = "0";
  TIMELINE_LIMIT_MONTHLY = "0";
  TIMELINE_LIMIT_YEARLY = "0";
};
```

Result: ~24 hourly + 7 daily ≈ 30 snapshots, no snapshot older than ~7 days.

## Snapshot types

- **timeline** — single snapshots created every `snapshotInterval` (default hourly).
- **pre/post** — a pair around a change; create with
  `snapper -c home create -t pre -p` then `... create -t post --pre-number N`,
  or `snapper -c home create --command '<cmd>'`.
- **boot** — on every boot, for the `root` config (`snapshotRootOnBoot = true`).
- **number** — cleaned by the `number` algorithm (keep last N), used for
  pre/post and manual snapshots.

Cleanup algorithms: `number`, `timeline`, `pre`, `post`, `empty`.
Pick one with `-c <algo>` on `snapper create`.

## CLI

```bash
snapper list-configs                       # show all configs
snapper -c home list                       # list snapshots for "home"
snapper -c home create -d "before change"  # manual snapshot (no cleanup)
snapper -c home create -c timeline -d x    # manual + timeline cleanup
snapper -c home status 1..5                # changed files between snapshots
snapper -c home diff 1..5 /path/file       # diff a single file
snapper -c home undochange 1..5            # revert changes 1→5
snapper -c home delete 5                   # delete one (use --sync to free space)
snapper -c home delete 5-10                # delete a range
```

Logs: `/var/log/snapper.log`.

## Filesystem layout note

Snapper stores snapshots in `<SUBVOLUME>/.snapshots/<N>/snapshot`. The
`.snapshots` dir **must be a btrfs subvolume owned by root** (the NixOS module
creates it automatically). Snapshots are read-only by default.

## btrfs-assistant

`btrfs-assistant` (GUI) is a **Snapper-only** front-end — it reads
`/etc/snapper/configs/*` and provides snapshot browsing, file restore and diff
views. It does **not** support btrbk. Installing both snapper + btrfs-assistant
gives full GUI snapshot management.

## btrbk vs Snapper (quick comparison)

| Feature              | btrbk                | Snapper                  |
|----------------------|----------------------|--------------------------|
| Local snapshots      | yes                  | yes                      |
| Remote backup (send) | yes (built-in)       | no (use external tool)   |
| GUI                  | no                   | btrfs-assistant          |
| Boot/rollback        | no                   | yes (with grub-btrfs)    |
| Config style         | retention policy str | per-granularity limits   |
