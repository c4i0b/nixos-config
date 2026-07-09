# Input Method

NixOS fcitx5 setup for KDE Plasma 6 + Wayland.

### Base config

```nix
i18n.inputMethod = {
  enable = true;
  type = "fcitx5";
  fcitx5 = {
    ignoreUserConfig = true;
  };
};
```

### Key points

- **`ignoreUserConfig = true`** — forces fcitx5 to use only `/etc/xdg/fcitx5/` configs, ignoring `~/.config/fcitx5/`. This prevents leftover user-level `profile` from overriding system settings and keeps the keyboard layout from resetting on login.
- Do **not** add fcitx5 packages to `environment.systemPackages` — the module handles it via `fcitx5-with-addons`.
- Configure input methods and layout via `fcitx5-config-qt` (GUI).

### Addons

Add to `fcitx5.addons`:

| Addon | Use |
|-------|-----|
| `fcitx5-mozc` | Japanese (Mozc) |
| `fcitx5-chewing` | Traditional Chinese (Chewing) |
| `fcitx5-chinese-addons` | Simplified Chinese (Pinyin, Shuangpin, Wubi) |
| `fcitx5-rime` | Rime engine (Chinese, custom) |
| `fcitx5-hangul` | Korean |
| `fcitx5-unikey` | Vietnamese |
| `fcitx5-table-extra` | Extra table-based IMEs (Cangjie, etc.) |

### GUI config tool

```nix
environment.systemPackages = with pkgs.kdePackages; [ fcitx5-configtool ];
```

Then open from System Settings → search "Fcitx5", or run `fcitx5-config-qt`.

### Ignore user config

```nix
i18n.inputMethod.fcitx5 = {
  ignoreUserConfig = true;
};
```

When enabled, fcitx5 uses only the system-wide config in `/etc/xdg/fcitx5/`. Settings changed via GUI are discarded on next reboot. Useful to guarantee a specific layout persists.

### Declarative settings (optional)

When `ignoreUserConfig` is not set, you can still declare defaults to avoid the layout reset cycle:

```nix
i18n.inputMethod.fcitx5.settings = {
  inputMethod = {
    "Groups/0" = {
      Name = "Default";
      "Default Layout" = "";
      DefaultIM = "keyboard-us";
    };
    "Groups/0/Items/0" = {
      Name = "keyboard-us";
      Layout = "";
    };
    "Groups/0/Items/1" = {
      Name = "mozc";
      Layout = "";
    };
  };
};
```

Use `"Default Layout" = ""` to inherit from system XKB instead of a specific layout.

### Hide system tray icon

```nix
i18n.inputMethod.fcitx5.settings.globalOptions."Behavior/DisabledAddons" = {
  "0" = "notificationitem";
  "1" = "classicui";
};
```

| Addon | Effect |
|-------|--------|
| `notificationitem` | System tray icon |
| `classicui` | Classic candidate window UI |
| `notification` | Popup notifications |
| `imselector` | Input method selector popup |
| `clipboard` | Clipboard history |
| `dbus` | D-Bus interface |
| `kimpanel` | KDE panel integration |

### Hide app launcher entries

```nix
let
  hide = name: desktopName: pkgs.makeDesktopItem {
    inherit name desktopName;
    type = "Application";
    noDisplay = true;
  };
in {
  environment.systemPackages = with pkgs; [
    (lib.hiPrio (hide "org.fcitx.Fcitx5" "Fcitx 5"))
    (lib.hiPrio (hide "fcitx5-config-qt" "Fcitx 5 Configuration"))
    (lib.hiPrio (hide "fcitx5-migrator" "Fcitx 5 Migrator"))
    (lib.hiPrio (hide "kbd-layout-viewer5" "Keyboard Layout Viewer"))
    (lib.hiPrio (hide "kcm_fcitx5" "Fcitx 5 KCM"))
  ];
}
```

### Prevent XKB override

```nix
i18n.inputMethod.fcitx5.settings.addons = {
  wayland.globalSection.AllowOverridingSystemXKBSettings = "False";
  xcb.globalSection.AllowOverridingSystemXKBSettings = "False";
};
```

### References

- https://wiki.nixos.org/wiki/Fcitx5
- https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
- https://fcitx-im.org/wiki/Setup_Fcitx_5
- https://fcitx-im.org/wiki/Configtool_(Fcitx_5)
