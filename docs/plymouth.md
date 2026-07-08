# Plymouth Boot Splash Reference

NVIDIA + Plymouth: the GPU driver takes time to initialize KMS, causing a black screen
between Limine and the splash. NixOS already sets `ShowDelay=0` for earliest possible
appearance; the delay comes from NVIDIA itself.

## Optimization

```nix
boot.consoleLogLevel = 3;
boot.initrd.verbose = false;
boot.kernelParams = [ "quiet" "splash" "rd.udev.log_level=3" "rd.systemd.show_status=auto" ];

boot.plymouth.extraConfig = ''
  ShowDelay=0                   # already the default; redundant but explicit
'';
```

## Preview themes without rebooting

Plymouth X11 renderer is **not available** in the nixpkgs package. Instead, see
animated GIF previews of all 80 adi1090x themes at:
https://github.com/adi1090x/plymouth-themes#previews

To download: `for i in $(seq 1 80); do curl -sLO "https://raw.githubusercontent.com/adi1090x/files/master/plymouth-themes/previews/${i}.gif"; done`

## Theme selection

```nix
boot.plymouth.theme = "spin";
boot.plymouth.themePackages = with pkgs; [
  (adi1090x-plymouth-themes.override { selected_themes = [ "spin" ]; })
];
```

adi1090x themes are numbered 1–80. Replace both `theme` and `selected_themes` with the
desired theme name.

## External resources
- NixOS wiki (Plymouth): https://wiki.nixos.org/wiki/Plymouth
- adi1090x/plymouth-themes: https://github.com/adi1090x/plymouth-themes
