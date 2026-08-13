# nixos-config

Modular, flake-based NixOS configuration for a single host (`nixos`).

## Layout

```
nixos-config/
├── flake.nix              # entry point: nixpkgs nixos-26.05 + home-manager release-26.05
├── flake.lock            # pinned inputs (committed)
├── hosts/
│   └── nixos/            # host composition + hardware-configuration.nix
├── modules/
│   ├── nixos/            # system modules (base, boot, networking, ...)
│   │   └── services/     # optional services (audio, flatpak, snapshots, ...)
│   └── home-manager/     # Home Manager modules (shell, git, ...)
│       └── programs/
├── home/
│   └── caio.nix          # per-user Home Manager config + personal packages
├── pkgs/                 # custom package derivations (placeholder)
├── overlays/             # overlays, wired via modules/nixos/base.nix
└── lib/                  # shared helpers (placeholder)
```

Host composition lives in `hosts/nixos/default.nix`: imports are **explicit**, and
optional features are toggled either by (un)commenting an import (small features)
or via an `enable` option under the `my.*` namespace (reusable features, e.g.
`my.desktop.enable = true;`).

## Workflow

```bash
git pull --ff-only
nix flake check                       # validate (optional but recommended)
sudo nixos-rebuild test  --flake .#nixos   # try without setting the boot generation
sudo nixos-rebuild switch --flake .#nixos   # apply
```

Update inputs deliberately, not casually:

```bash
nix flake update            # all inputs   — review flake.lock diff before rebuilding
nix flake update nixpkgs    # single input
```

## Notes

- Base system runs on `nixos-26.05` (stable). The desktop stack (KDE Plasma /
  SDDM) and the entire user package set are pinned to `nixos-unstable` via the
  overlay in `overlays/default.nix` (`with pkgs.unstable;` in `home/caio.nix`).
- `system.autoUpgrade` is disabled by default. A GitHub commit does not pull
  itself onto the machine; rebuild manually. See `modules/nixos/base.nix` for how
  to re-enable local-only automatic rebuilds.
- `/etc/nixos` is a symlink to this repo. Setup details: `docs/README.md`.
