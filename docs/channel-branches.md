# Channel branches - Official NixOS Wiki

Nix channels provide a structured and reliable way to access package collections and NixOS configurations from the Nixpkgs repository.

## The official channels

- **Stable channels** (e.g. `nixos-26.05`, `nixos-26.11`): conservative updates for bug fixes and security. Check https://nixos.org/download/ for current stable.
- **Unstable channels** (`nixos-unstable`, `nixpkgs-unstable`): follow master branch, latest tested updates.
- **Large channels**: updated after Hydra builds full Nixpkgs.
- **Small channels** (e.g. `nixos-*-small`): updated faster with fewer binary packages.

## nix-channel commands

| Action | Command |
|--------|---------|
| List channels | `nix-channel --list` |
| Add primary channel | `nix-channel --add https://channels.nixos.org/channel-name nixos` |
| Add other channel | `nix-channel --add https://some.channel/url my-alias` |
| Remove channel | `nix-channel --remove channel-alias` |
| Update channel | `nix-channel --update channel-alias` |
| Update all | `nix-channel --update` |
| Rollback | `nix-channel --rollback` |

Source: https://wiki.nixos.org/wiki/Channel_branches
