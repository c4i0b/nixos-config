# Fresh Install / Deploy

Sources:
- NixOS Manual — Installing: https://nixos.org/manual/nixos/stable/#sec-installation
- NixOS Manual — Manual Installation: https://nixos.org/manual/nixos/stable/#sec-installation-manual
- NixOS Wiki — Btrfs: https://wiki.nixos.org/wiki/Btrfs
- disko (declarative partitioning): https://github.com/nix-community/disko
- disko quickstart: https://github.com/nix-community/disko/blob/master/docs/quickstart.md

## The one rule
Enable btrfs compression **at mount time, during install** — not after.

`nixos-install` writes the whole system (closure, store, home) to whatever is mounted on
`/mnt`. If `/mnt` is mounted with `-o compress=zstd`, everything is **born compressed** and no
defrag is ever needed. Setting `fileSystems.*.options` in the config only affects mounts on
future boots — it does not touch data already on disk (see ./btrfs.md,
./btrfs-compress-existing.md).

This repo's `configuration.nix` already declares `compress=zstd` on `/`, `/home`, `/nix`, so
it persists on every boot. The only thing to get right is the install-time mount.

## Layout (this repo)
Single btrfs filesystem:
- `/`     → top-level subvolume (subvolid 5)
- `/home` → subvolume `home`
- `/nix`  → subvolume `nix`
- `/boot` → separate vfat (ESP)

## Option A — Manual install (channels, matches this repo)
Boot the minimal ISO, `sudo -i`, get networking up.

```bash
DEV=/dev/nvme0n1   # adjust!

# 1. Partition (UEFI/GPT)
parted $DEV -- mklabel gpt
parted $DEV -- mkpart ESP fat32 1MiB 512MiB
parted $DEV -- set 1 esp on
parted $DEV -- mkpart root btrfs 512MiB 100%

# 2. Format
mkfs.fat -F 32 -n boot ${DEV}p1
mkfs.btrfs -L nixos ${DEV}p2

# 3. Subvolumes (match this repo)
mount /dev/disk/by-label/nixos /mnt
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
umount /mnt

# 4. Mount WITH compress=zstd   <-- the critical step
mount -o compress=zstd                   /dev/disk/by-label/nixos /mnt
mount -o compress=zstd,subvol=home --mkdir /dev/disk/by-label/nixos /mnt/home
mount -o compress=zstd,subvol=nix  --mkdir /dev/disk/by-label/nixos /mnt/nix
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# 5. Hardware config for THIS disk (UUIDs/subvols/compress auto-detected)
nixos-generate-config --root /mnt

# 6. Replace configuration.nix with this repo's, keep the generated hardware-configuration.nix
git clone git@github.com:c4i0b/nixos-config.git /tmp/nixos-config
cp /tmp/nixos-config/configuration.nix /mnt/etc/nixos/configuration.nix

# 7. Install — every byte written is compressed
nixos-install
reboot
```

> `hardware-configuration.nix` is machine-specific (disk UUIDs). Never reuse the repo's copy on
> a different disk — let `nixos-generate-config` create a fresh one (step 5).

## Option B — Declarative install with disko (recommended for multiple machines)
disko declares the disk layout (partitions, subvolumes, mount options incl. `compress=zstd`)
in the repo, so one config reproduces identical disks on any machine — no manual mount step,
compression guaranteed. It works alongside channels (the system config stays channel-based;
only invoking the disko tool needs the `flakes` experimental flag).

Minimal `disko-config.nix` (btrfs + zstd), from the official example:

```nix
{ ... }: {
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-...";   # use by-id, not /dev/sdX
    content = {
      type = "gpt";
      partitions = {
        ESP = { size = "1G"; type = "EF00"; content = {
          type = "filesystem"; format = "vfat"; mountpoint = "/boot";
          mountOptions = [ "umask=0077" ];
        }; };
        root = { size = "100%"; content = {
          type = "btrfs"; extraArgs = [ "-f" ];
          subvolumes = {
            "/rootfs" = { mountpoint = "/";     mountOptions = [ "compress=zstd" "noatime" ]; };
            "/home"   = { mountpoint = "/home"; mountOptions = [ "compress=zstd" ]; };
            "/nix"    = { mountpoint = "/nix";  mountOptions = [ "compress=zstd" "noatime" ]; };
          };
        }; };
      };
    };
  };
}
```

```bash
# from the official quickstart
sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest -- --mode destroy,format,mount /tmp/disko-config.nix
nixos-generate-config --no-filesystems --root /mnt   # disko owns the FS config
# import the disko module + ./disko-config.nix in configuration.nix, then:
nixos-install
```

## Compression level
`compress=zstd` == `compress=zstd:3` (level 3 — the default Arch and Fedora ship). No need to
pin the level.

## Verify after install
```bash
findmnt -o TARGET,OPTIONS / | grep compress    # mount option active
sudo compsize -x /                             # almost everything compressed from byte 0
df -h /
```
