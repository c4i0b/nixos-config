# Limine Bootloader — NixOS Reference

Sources: https://wiki.nixos.org/wiki/Limine, https://github.com/limine-bootloader/limine/blob/trunk/CONFIG.md

## Enable

```nix
boot.loader.limine.enable = true;
```

## Instant Boot (no menu flash)

```nix
boot.loader.timeout = 0;
boot.loader.limine.extraConfig = ''
  quiet: yes
'';
```

- `timeout: 0` — boots default entry instantly
- `quiet: yes` — suppresses all screen output (no wallpaper, no interface)
- Press **any key** during early boot to show the menu

## NixOS Options

| Option | Description |
|--------|-------------|
| `boot.loader.timeout` | Timeout in seconds. `null` = wait forever, `0` = boot instantly |
| `boot.loader.limine.enableEditor` | Allow editing kernel params at boot (default: `false`) |
| `boot.loader.limine.maxGenerations` | Limit boot entries (default: no limit) |
| `boot.loader.limine.extraConfig` | Raw text **prepended** to `limine.conf` |
| `boot.loader.limine.extraEntries` | Raw text **appended** to `limine.conf` |
| `boot.loader.limine.resolution` | Framebuffer resolution (e.g. `"1920x1080x32"`) |
| `boot.loader.limine.validateChecksums` | Verify file checksums before boot (default: `true`) |
| `boot.loader.limine.panicOnChecksumMismatch` | Panic on checksum mismatch |
| `boot.loader.limine.style.wallpapers` | List of wallpaper paths (BMP/PNG/JPEG/QOI) |
| `boot.loader.limine.style.wallpaperStyle` | `centered`, `stretched`, or `tiled` |
| `boot.loader.limine.style.backdrop` | Background colour (RRGGBB) |
| `boot.loader.limine.style.interface.branding` | Title at top of screen |
| `boot.loader.limine.style.interface.brandingColor` | Title colour (RRGGBB) |
| `boot.loader.limine.style.interface.helpHidden` | Hide keybind hints |
| `boot.loader.limine.style.interface.resolution` | UI-specific resolution (menu only, not OS) |
| `boot.loader.limine.style.graphicalTerminal.*` | Font, palette, margin settings |

## Global Config Options (via `extraConfig`)

| Option | Values | Description |
|--------|--------|-------------|
| `timeout` | seconds / `no` / `0` | Auto-boot timeout. `no` = wait forever, `0` = instant |
| `quiet` | `yes` / `no` | Suppress all output. Key press reveals menu |
| `default_entry` | number / path | 1-based index or entry path for default selection |
| `graphics` | `yes` / `no` | `no` = force text mode |
| `keyboard_layout` | `dvorak` | Remap keyboard for menu/editor |
| `firmware_logo` | `yes` / `no` | UEFI: restore OEM boot logo instead of blank screen |
| `remember_last_entry` | `yes` / `no` | UEFI: remember last booted entry |
| `verbose` | `yes` / `no` | Print additional boot info |
| `hash_mismatch_panic` | `yes` / `no` | `no` = warn instead of panic on hash mismatch |
| `serial` | `yes` / `no` | Enable serial I/O (BIOS only) |
| `interface_resolution` | `<W>x<H>` | Menu UI resolution (e.g. `1920x1080`) |
| `interface_branding` | string | Title text at top of menu |
| `interface_branding_colour` | RRGGBB | Branding colour (default: `00aaaa`) |
| `interface_help_hidden` | `yes` / `no` | Hide keybind help text |
| `interface_help_colour` | RRGGBB | Help text colour (default: `00aa00`) |
| `editor_enabled` | `yes` / `no` | Allow editing boot entries |
| `editor_highlighting` | `yes` / `no` | Syntax highlighting in editor |
| `editor_validation` | `yes` / `no` | Validate config in editor |
| `term_font_scale` | e.g. `2x2` | Font scaling for high-DPI |
| `term_font_spacing` | pixels | Horizontal spacing between glyphs |
| `term_palette` | RRGGBB;... | 8-colour terminal palette |
| `term_background` | TTRRGGBB | Terminal background (TT = transparency) |
| `term_foreground` | RRGGBB | Terminal foreground colour |
| `term_margin` | pixels | Margin around terminal |
| `term_margin_gradient` | pixels | Gradient thickness around terminal |

## `boot.loader.timeout` Behaviour

| Value | Behaviour |
|-------|-----------|
| `null` | `timeout: no` — wait forever, no auto-boot |
| `0` | `timeout: 0` — boot default instantly; any key shows menu |
| `5` | `timeout: 5` — wait 5 seconds, then auto-boot |
| `0` + `quiet: yes` | No screen output at all; any key reveals menu |

## Example: Minimal / Hide All

```nix
boot.loader.timeout = 0;
boot.loader.limine.extraConfig = ''
  quiet: yes
  interface_help_hidden: yes
  editor_enabled: no
'';
```

## Example: Custom Menu with Branding

```nix
boot.loader.timeout = 10;
boot.loader.limine = {
  style = {
    wallpapers = [ pkgs.nixos-artwork.wallpappers.simple-dark-gray-bootloader.gnomeFilePath ];
    wallpaperStyle = "centered";
    backdrop = "000000";
    interface = {
      branding = "NixOS";
      brandingColor = "00FFAA";
    };
  };
};
```

## Testing in VM

```bash
sudo nixos-rebuild build-vm-with-bootloader
./result/bin/run-nixos-vm
```

Requires a temp user:

```nix
users.users.nixosvmtest = { isNormalUser = true; initialPassword = "test"; };
```
