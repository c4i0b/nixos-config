# NixOS Configuration

## Setup on a new machine

```bash
git clone https://github.com/c4i0b/nixos-config.git ~/Projects/nixos-config
sudo mv /etc/nixos /etc/nixos.bak      # if present
sudo ln -s ~caio/Projects/nixos-config /etc/nixos
cd ~/Projects/nixos-config
nix flake lock                          # generate flake.lock on first use
sudo nixos-rebuild switch --flake .#nixos
```

> `/etc/nixos` is a symlink to this repo. Rebuilds use the flake entry point (`.#nixos`), not `/etc/nixos/configuration.nix`.

> For a from-scratch install (partition, format, compression from byte 0), see ./fresh-deploy.md.

# NixOS Documentation References

## Official Manuals
- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Nixpkgs Manual**: https://nixos.org/manual/nixpkgs/stable/
- **Nix Manual**: https://nixos.org/manual/nix/stable/
- **NixOS Options**: https://search.nixos.org/options
- **Nixpkgs Packages**: https://search.nixos.org/packages

## Configuration
- `nixos-help` - view NixOS manual offline
- `man configuration.nix` - configuration syntax reference
- `nixos-option` - inspect option values

## Channel Management
- Channel status: https://status.nixos.org
- Channel branches: ./channel-branches.md

## Reference Docs
- Plymouth boot splash: ./plymouth.md
- Audio (PipeWire + kernel modprobe): ./audio.md

## NixOS Wiki
- https://wiki.nixos.org/

## Inputs / updating

This config is flake-based. nixpkgs is pinned to `nixos-26.05` and home-manager to `release-26.05` (see `flake.lock`, which is committed).

```bash
nix flake update            # bump all inputs (review the diff, then rebuild)
nix flake update nixpkgs    # bump a single input
nix flake check             # validate the flake
```

To follow nixos-unstable instead of stable, change the inputs in `flake.nix`:
```nix
nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
home-manager.url = "github:nix-community/home-manager/master";
```
