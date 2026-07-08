# Automatic System Upgrades on NixOS

Source: https://wiki.nixos.org/wiki/Automatic_system_upgrades

## Channel-based (default)

```nix
system.autoUpgrade = {
  enable = true;
  dates = "02:00";
  randomizedDelaySec = "45min";
  allowReboot = false;  # true for automatic reboots
};
```

**Important:** Do not use flake-specific flags with channel-based systems.

## Flake-based

```nix
system.autoUpgrade = {
  enable = true;
  flake = "/path/to/flake";
  flags = [ "--print-build-logs" ];
  dates = "02:00";
  randomizedDelaySec = "45min";
};
```

## Garbage Collection

Auto-upgrade without GC fills up `/boot` and `/`. Pair with:

```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
};

nix.optimise.automatic = true;
```

`30d` is the recommended retention (balances rollback safety vs disk usage).

## Monitoring

```bash
systemctl start nixos-upgrade        # force run
systemctl status nixos-upgrade.service
journalctl -u nixos-upgrade.service
systemctl status nixos-upgrade.timer
```
