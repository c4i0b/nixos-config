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
nix build .#nixosConfigurations.Fedora.config.system.build.vm  # build VM image
nix fmt                                       # format with alejandra (via flake formatter)
```

After any edit, stage new files with `git add` before running `nix flake check`. Nix refuses to evaluate untracked files.

## Repo: c4i0b/nixos-config, author: Caio <cbrunofb@gmail.com>

## Architecture

Template base: `standard/` from Misterio77/nix-starter-configs. Structure matches template exactly.

```
flake.nix                    inputs, overlays, nixosConfigurations
nixos/configuration.nix      orchestrator: nixpkgs, nix, locale, imports, stateVersion
nixos/hardware-configuration.nix  placeholder btrfs/EFI layout (NEEDS_GENERATION UUIDs)
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
| `boot.nix` | Yes | kernel (linuxPackages_zen), loader, filesystems |
| `gpu.nix` | No | NVIDIA RTX 5080 (Blackwell): `open = true`, videoDrivers, graphics |
| `desktop.nix` | Yes | xserver, xkb, pipewire, flatpak, fwupd, fonts |
| `gnome.nix` | No | gnome, gdm, excludePackages, gnome-extensions-cli, gnome-tweaks |
| `networking.nix` | Yes | hostname, networkmanager, firewall |
| `users.nix` | Yes | user caio, SSH key, groups |
| `services.nix` | Yes | fish, openssh |
| `gaming.nix` | Yes | steam (unstable), udev, proton env vars |
| `virtualisation.nix` | Yes | docker, libvirtd |
| `packages.nix` | Yes | all system packages |
| `browser-policies.nix` | No | firefox policies, brave policies via environment.etc |

To switch DE: delete `gnome.nix`, rewrite `desktop.nix`.

### Overlay system

- `additions`: custom packages from `pkgs/` + `accela` from enter-the-wired flake
- `modifications`: empty (for package overrides)
- `unstable-packages`: exposes `pkgs.unstablePkgs` from nixpkgs-unstable

Stable is the default package source. Only actively-developed tools use `pkgs.unstablePkgs.xxx` (bat, btop, eza, fastfetch, opencode, superfile, tealdeer, brave, libreoffice, steam).

### Flake inputs

- `nixpkgs`: `nixos-26.05` (stable base)
- `nixpkgs-unstable`: `nixos-unstable` (unstable overlay)
- `home-manager`: `release-26.05`, follows nixpkgs
- `nixos-hardware`: `common-cpu-amd`, `common-gpu-nvidia` (in nixosConfigurations modules, not as imports)
- `enter-the-wired`: ACCELA + SLSsteam package

`homeConfigurations` is commented out (dotfiles managed via GNU stow at `Projects/dotfiles`, not home-manager).

## NVIDIA RTX 5080 specifics

- `hardware.nvidia.open = true` is **required** for Blackwell (proprietary modules unsupported)
- No manual kernel params or `extraModulePackages` — the NixOS nvidia module handles everything
- `prime.offload.enable = false` (no iGPU, Ryzen 7800X3D)
- Driver: `nvidiaPackages.stable` (595.71.05, production branch)

## Key constraints

- Keep template comments style: `# Opinionated:`, `# FIXME`, `# TODO`, `# > Our main nixos configuration file <`
- Config stays **inline in nixos/*.nix** — no split sub-modules
- `hardware-configuration.nix` has `NEEDS_GENERATION` UUIDs — must be replaced with `nixos-generate-config` output on real install
- Home-manager `home.stateVersion` still says `25.11` (intentional — HM is disabled)
- `enter-the-wired` flake emits evaluation warning: `'system' renamed to 'stdenv.hostPlatform.system'` (upstream, not our issue)
