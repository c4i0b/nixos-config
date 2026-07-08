# Bluetooth on NixOS

Source: https://wiki.nixos.org/wiki/Bluetooth

## Enable

```nix
hardware.bluetooth.enable = true;
```

## GUI (optional, KDE has built-in bluedevil)

```nix
services.blueman.enable = true;
```

## CLI pairing

```bash
bluetoothctl
power on
agent on
default-agent
scan on
pair <addr>
connect <addr>
trust <addr>
```

## Audio codecs (AAC, APTX, LDAC)

```nix
hardware.pulseaudio.package = pkgs.pulseaudioFull;
```

## Battery level

```nix
hardware.bluetooth.settings.General.Experimental = true;
```

## Troubleshooting

- `rfkill unblock bluetooth` if blocked
- `systemctl restart bluetooth` after config changes
- Restart display-manager if dbus access denied
