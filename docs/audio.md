# Audio — NixOS Reference

Official docs: https://wiki.nixos.org/wiki/PipeWire
PipeWire docs: https://docs.pipewire.org/
WirePlumber (ALSA rules): https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html

## Active in current config

- PipeWire as the sound server (default for graphical sessions since NixOS 24.11)
- ALSA + ALSA 32-bit + PulseAudio compatibility layers
- `rtkit` for realtime scheduling
- HDA Intel power saving **disabled** via modprobe (prevents idle pops/clicks)

```nix
services.pulseaudio.enable = false;
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
};
```

## Kernel module options (modprobe)

To pass options to a kernel module — the NixOS equivalent of
`/etc/modprobe.d/<name>.conf` — use `boot.extraModprobeConfig`:

```nix
boot.extraModprobeConfig = ''
  options snd_hda_intel power_save=0 power_save_controller=N
'';
```

This writes the line verbatim into `/etc/modprobe.d/nixos.conf`.

> `boot.extraModprobeConfig` is type `lines`, so the module system merges
> definitions coming from **different modules**. Within a single
> `configuration.nix`, however, an attribute can be assigned only once — so
> all module options (e.g. the NVIDIA `color_pipeline` workaround and the
> audio `power_save` option) must share one `boot.extraModprobeConfig` block.
> `#` lines inside the string are valid modprobe comments and keep each
> option's context next to it.

### snd_hda_intel power_save

- `power_save=0` — never auto-suspend the codec (default: autosuspend after N
  seconds). Stops the audible "pop" when the controller powers down on idle.
- `power_save_controller=N` — do not power off the HDA controller itself when
  no codecs are active.

Equivalent legacy file (`/etc/modprobe.d/snd-hda-intel.conf`):
```
options snd_hda_intel power_save=0 power_save_controller=N
```

## Alternatives: PipeWire/WirePlumber-level fixes

The modprobe option is a blunt, kernel-level hammer. PipeWire can also cause
pops by suspending nodes after 5s of inactivity — fix that at the session
manager level instead, which is more granular (per-device) and survives module
changes:

```nix
# Disable node suspend so devices don't pop on idle (all ALSA devices).
services.pipewire.wireplumber.extraConfig."99-disable-suspend" = {
  "monitor.alsa.rules" = [
    {
      matches = [
        { "node.name" = "~alsa_input.*"; }
        { "node.name" = "~alsa_output.*"; }
      ];
      actions.update-props = {
        "session.suspend-timeout-seconds" = 0;
      };
    }
  ];
};
```

To target a single device, find its node name with `pw-dump | grep node.name |
grep alsa` (or `pw-top`) and match it exactly instead of the wildcard.

After changing wireplumber config, restart it as your user:
```bash
systemctl --user restart wireplumber
```
(`nixos-rebuild switch` alone is not enough — wireplumber runs per-user.)

## Troubleshooting

- `pw-top` — monitor PipeWire graph; suspended nodes drop their numeric columns.
- `pw-dump | grep node.name` — list ALSA node names.
- `wpctl status` — high-level device list (like old `pactl`).
- `pavucontrol` / `pwvucontrol` — GUI volume & routing.
- Crackling: increase quantum/buffer (see PipeWire wiki "Audio Crackling Fix").
- Startup delay after boot/suspend: combine `session.suspend-timeout-seconds = 0`
  with `"node.always-process" = true`.

## See also
- PipeWire low-latency / bluetooth config: https://wiki.nixos.org/wiki/PipeWire
- Kernel module loading in general: ./kernel.md
