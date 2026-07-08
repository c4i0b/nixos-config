# NixOS Configuration

## Setup on a new machine

```bash
git clone git@github.com:c4i0b/nixos-config.git ~/Projects/nix-config
sudo mv /etc/nixos /etc/nixos.bak
sudo ln -s ~caio/Projects/nix-config /etc/nixos
sudo nixos-rebuild switch
```

> `/etc/nixos` is a symlink to this repo — any change here is picked up by `nixos-rebuild`.

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

## NixOS Wiki
- https://wiki.nixos.org/

## Cheat Sheet (unstable packages via channels)
```bash
# Add unstable channel (as root)
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update

# Use in configuration.nix:
# { config, pkgs, ... }:
# let
#   unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
# in {
#   environment.systemPackages = with pkgs; [
#     # stable packages
#   ] ++ (with unstable; [
#     # unstable packages
#   ]);
# }
```
