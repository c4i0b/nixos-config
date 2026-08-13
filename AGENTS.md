# NixOS Config — Agent Guide

## Rebuild (flake-based)
```bash
sudo nixos-rebuild test   --flake .#nixos   # validate without making it the boot default
sudo nixos-rebuild switch --flake .#nixos   # apply and set as the boot generation
```
Run from the repo root (this flake). `test` first, then `switch`.

## Search packages
```bash
nix-search <term>
```
Faster alternative to `nix search` / `nix-env -qaP`.

## Update inputs
```bash
nix flake update            # update all inputs (review flake.lock diff after)
nix flake update nixpkgs    # update a single input
nix flake check             # validate before rebuilding
```
`flake.lock` is committed and reviewed like any other change.

## Structure
- `/etc/nixos` → symlink to this repo (or a checkout of it)
- `flake.nix` / `flake.lock` — entry point; pins nixpkgs `nixos-26.05` + home-manager `release-26.05`
- `hosts/nixos/` — host composition (`default.nix`) + `hardware-configuration.nix` (auto-generated; **do not edit**)
- `modules/nixos/` — system modules (base, boot, networking, localization, hardware, users, desktop, programs, packages, systemd)
- `modules/nixos/services/` — optional service modules (audio, flatpak, snapshots, virtualisation, ssh)
- `modules/home-manager/` — Home Manager modules (base, shell, git, programs/neovim)
- `home/caio.nix` — per-user Home Manager config + personal packages
- `pkgs/`, `overlays/`, `lib/` — custom packages, overlays and helpers (mostly placeholders)
- `docs/` — reference docs
- Git repo: `https://github.com/c4i0b/nixos-config.git`

## Conventions
- Imports are **explicit** and listed at the top of `hosts/nixos/default.nix`.
- Comment out an `imports` entry to disable a small/local feature.
- For reusable features, use an `enable` option under the `my.*` namespace (see `desktop.nix`, `services/ssh.nix`). The host then opts in with e.g. `my.desktop.enable = true;`.
- Don't create an `enable` option when "module imported == feature on" is good enough.
- Personal/user packages belong in Home Manager (`home/caio.nix`); system-wide packages stay in `modules/nixos/packages.nix`.
- Packages too new for (or missing from) stable nixpkgs are pulled from `nixpkgs-unstable` via the `pkgs.unstable` overlay (see `overlays/default.nix`). The entire user package set (`home/caio.nix`) uses `with pkgs.unstable;`, and the KDE/SDDM desktop stack is pinned to unstable via the same overlay; the system core stays on stable.

## Module map (former configuration.nix sections)
- 1 Boot & Kernel → `modules/nixos/boot.nix`
- 2 Networking → `modules/nixos/networking.nix` (+ `networking.hostName` in the host)
- 3 Localization → `modules/nixos/localization.nix`
- 4 Display & Desktop → `modules/nixos/desktop.nix` (enable option)
- 5 Hardware → `modules/nixos/hardware.nix`
- 6 Users → `modules/nixos/users.nix`
- 7 Security / Overrides → `modules/nixos/base.nix` (`allowUnfree`, overlays)
- 8 Services → `modules/nixos/services/{audio,flatpak,snapshots,virtualisation}.nix`
- 9 Programs → `modules/nixos/programs.nix` (fish/steam/gamemode)
- 10 Virtualization → `modules/nixos/services/virtualisation.nix`
- 11 Systemd → `modules/nixos/systemd.nix`
- 12 System Packages → `modules/nixos/packages.nix` + `home/caio.nix` (personal)
- 13 State & Maintenance → `modules/nixos/base.nix` (gc, optimise; autoUpgrade disabled by default)

## User & host
- Hostname: `nixos` (flake output `.#nixos`)
- Username: `caio`, password: set externally
- Home: `/home/caio`

## Notes
- nixpkgs was moved from `nixos-unstable` (channel) to `nixos-26.05` (flake). Some packages that existed only in unstable may need to be removed or the input switched back to unstable.
- `system.autoUpgrade` is disabled by default (flakes + auto-pull can break a personal machine without review). Rebuild manually; see base.nix for how to re-enable local-only upgrades.
