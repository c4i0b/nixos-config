# NixOS Config — Agent Guide

## Rebuild
```bash
sudo nixos-rebuild switch
```

## Search packages
```bash
nix-search <term>
```
Faster & channel-compatible alternative to `nix search` / `nix-env -qaP`.

## Structure
- `/etc/nixos` → **symlink** to `~/Projects/nix-config` — changes here reflect directly to the system
- `~/Projects/nix-config/configuration.nix` — single file, 13 numbered sections
- `~/Projects/nix-config/hardware-configuration.nix` — auto-generated; **do not edit**
- `~/Projects/nix-config/docs/` — reference docs
- This is a git repo at `git@github.com:c4i0b/nixos-config.git`

## Channels (not flakes)
- Prefer channels over flakes
```nix
unstable = import <nixos-unstable/nixpkgs> { config = { allowUnfree = true; }; };
```
Prefix with `unstable.` inside `environment.systemPackages` for unstable packages.

## Sections (numbered 1–13 in configuration.nix)
- 1: Boot & Kernel (Limine, Plymouth, latest kernel)
- 2: Networking
- 3: Localization (cedilla fix, US console keymap, ibus)
- 4: Display & Desktop (SDDM + Plasma 6, minimal KDE packages)
- 5: Hardware (NVIDIA open modules, Storage, Btrfs scrub, Bluetooth)
- 6: Users
- 7: Security & Package Overrides
- 8: Services (PipeWire, Flatpak, Snapper snapshots, VirtualBox)
- 9: Programs / NixOS modules (fish, steam, gamemode)
- 10: Virtualization (Podman with dockerCompat, containers)
- 11: Systemd (tmpfiles, topgrade user service/timer)
- 12: System Packages (organized by category; prefix `unstable.` for nixos-unstable)
- 13: System State & Maintenance (autoUpgrade, nix gc)

## User & host
- Hostname: `nixos`
- Username: `caio`, password: set externally
- Home: `~` (i.e. `/home/caio`)

## Conventions
- Packages stay organized in section 12 categories with empty placeholders for future additions
- New options go into an existing section or create a new numbered section at the end
- Comments are minimal

## Docs
- `docs/README.md` — NixOS manual links, channel cheat sheet
- `docs/useful-options.md` — common NixOS options (Docker, Bluetooth, fonts, etc.)
- `docs/nvidia-gaming.md` — NVIDIA + gaming setup
- `docs/systemd.md` — systemd services & timers (system and user level)
- `docs/channel-branches.md` — NixOS channel branches reference
- `docs/snapper.md` — Snapper snapshot setup
- `docs/bluetooth.md` — Bluetooth configuration notes
- `docs/btrfs.md` — Btrfs filesystem notes
- `docs/btrfs-compress-existing.md` — compress existing data (defrag)
- `docs/fresh-deploy.md` — fresh install with compression from the start
- `docs/build-vm.md` — building a NixOS VM for testing
- `docs/distrobox.md` — Distrobox container setup
- `docs/limine.md` — Limine bootloader notes
- `docs/plymouth.md` — Plymouth splash screen notes
- `docs/podman.md` — Podman container notes
- `docs/auto-upgrade.md` — automatic upgrade notes
