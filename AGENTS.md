# NixOS Configuration for c4i0b/nixos-config

## Environment

Nix installed as single-user at `~/.nix-profile/`. Every `nix` or `nixos-*` command requires prepending:
```bash
export PATH="$HOME/.nix-profile/bin:$PATH"
export NIX_CONFIG="experimental-features = nix-command flakes"
```

Shell is `fish` — the nix profile script has a bash syntax error, source `.nix-profile/etc/profile.d/nix.sh` instead.

## Commands

```bash
nix flake check                              # validate config (files must be git-tracked first)
nix fmt                                       # format with alejandra (via flake formatter)
```

After any edit, stage new files with `git add` before running `nix flake check`. Nix refuses to evaluate untracked files.

Rebuild via: `git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos`

For privilege escalation: `/run/wrappers/bin/pkexec env PATH="$HOME/.nix-profile/bin:/run/current-system/sw/bin:$PATH" nixos-rebuild switch --flake /etc/nixos`

## Repo: c4i0b/nixos-config, author: Caio <cbrunofb@gmail.com>

## Architecture

Template base: `standard/` from Misterio77/nix-starter-configs. Structure matches template exactly.

```
flake.nix                    inputs, overlays, nixosConfigurations
nixos/configuration.nix      orchestrator: nixpkgs, nix, locale, imports, stateVersion
nixos/hardware-configuration.nix  generated btrfs/EFI layout with real UUIDs
nixos/*.nix                 per-domain modules, imported by configuration.nix
home-manager/home.nix        skeleton template, HM disabled (dotfiles via stow)
overlays/default.nix          additions (pkgs/ + enter-the-wired), modifications (empty), unstable-packages (pkgs.unstablePkgs)
pkgs/default.nix              empty skeleton for custom derivations
modules/nixos/default.nix     empty skeleton
modules/home-manager/default.nix empty skeleton
```

### Module map

| Module | DE-agnostic? | Contains |
|--------|-------------|----------|
| `boot.nix` | Yes | kernel (linuxPackages_latest), loader, filesystems |
| `gpu.nix` | No | NVIDIA RTX 5080 (Blackwell): `open = true`, videoDrivers, graphics |
| `desktop.nix` | Yes | xserver, xkb, pipewire, fwupd, fonts (flatpak commented out) |
| `gnome.nix` | No | gnome, gdm, excludePackages, gnome-extensions-cli, gnome-tweaks |
| `networking.nix` | Yes | hostname, networkmanager, firewall |
| `users.nix` | Yes | user caio, SSH key, groups |
| `services.nix` | Yes | fish shell aliases, openssh, topgrade timer |
| `gaming.nix` | Yes | steam (unstable), udev, proton env vars, SLSsteam LD_AUDIT injection |
| `virtualisation.nix` | Yes | docker, libvirtd, vmware-workstation |
| `packages.nix` | Yes | all system packages |
| `browser-policies.nix` | No | firefox policies, brave policies via environment.etc |

To switch DE: delete `gnome.nix`, rewrite `desktop.nix`.

### Overlay system

- `additions`: custom packages from `pkgs/` + `accela` from enter-the-wired flake
- `modifications`: appimage-run (zstd), pop-shell gnome extension override
- `unstable-packages`: exposes `pkgs.unstablePkgs` from nixpkgs-unstable

Stable is the default package source. Actively-developed tools use `pkgs.unstablePkgs.xxx` (bat, btop, eza, fastfetch, lazygit, opencode, superfile, tealdeer, television, uv, brave, libreoffice). Steam is also from unstable (defined in gaming.nix).

### Flake inputs

- `nixpkgs`: `nixos-26.05` (stable base)
- `nixpkgs-unstable`: `nixos-unstable` (unstable overlay)
- `home-manager`: `release-26.05`, follows nixpkgs
- `nixos-hardware`: `common-cpu-amd`, `common-gpu-nvidia` (in nixosConfigurations modules, not as imports)
- `enter-the-wired`: ACCELA package (SLSsteam was moved to its own flake)
- `sls-steam`: `github:AceSLS/SLSsteam` (LD_AUDIT injection for Steam)
- `pop-shell`: `github:pop-os/shell/master_noble` (keyboard-driven GNOME layer, no flake)

`homeConfigurations` is commented out (dotfiles managed via GNU stow, not home-manager).

## NVIDIA RTX 5080 specifics

- `hardware.nvidia.open = true` is **required** for Blackwell (proprietary modules unsupported)
- No manual kernel params or `extraModulePackages` — the NixOS nvidia module handles everything
- `prime.offload.enable = false` (no iGPU, Ryzen 7800X3D)
- Driver: `nvidiaPackages.stable` (production branch)

## Key constraints

- Keep template comments style: `# Opinionated:`, `# FIXME`, `# TODO`, `# > Our main nixos configuration file <`
- Config stays **inline in nixos/*.nix** — no split sub-modules
- `hardware-configuration.nix` contains real UUIDs from this machine's `nixos-generate-config` output — replace with your own on a different machine
- `enter-the-wired` flake emits evaluation warning: `'system' renamed to 'stdenv.hostPlatform.system'` (upstream, not our issue)
