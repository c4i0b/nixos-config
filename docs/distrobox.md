# Distrobox — Official NixOS Wiki

Source: https://wiki.nixos.org/wiki/Distrobox

## Setup

```nix
virtualisation.podman.enable = true;
environment.systemPackages = [ pkgs.distrobox ];
```

## Usage

```bash
distrobox create --root --name archlinux --image archlinux:latest
distrobox enter --root archlinux
```

## Tips

### Cross-architecture

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```

```bash
sudo podman run --rm --privileged multiarch/qemu-user-static --reset -p yes
distrobox create -n debian --image arm64v8/debian
```

### subUID/subGID ranges

```nix
users.users.<USERNAME> = {
  extraGroups = [ "podman" ];
  subUidRanges = [{ startUid = 65536; count = 65536; }];
  subGidRanges = [{ startGid = 65536; count = 65536; }];
};
```

Must not overlap with the user's own UID/GID. After changing, run `podman system migrate` then create containers.

### Exposing profiles (avoid mount errors)

```nix
environment.etc."distrobox/distrobox.conf".text = ''
  container_additional_volumes="/nix/store:/nix/store:ro /etc/profiles/per-user:/etc/profiles/per-user:ro /etc/static/profiles/per-user:/etc/static/profiles/per-user:ro"
'';
```
