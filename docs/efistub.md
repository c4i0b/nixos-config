# EFISTUB — Direct Kernel Boot via UEFI

Sources: https://wiki.archlinux.org/title/EFI_boot_stub, https://docs.kernel.org/admin-guide/efi-stub.html, https://wiki.nixos.org/wiki/Bootloader
Manual: https://nixos.org/manual/nixos/stable/#sec-bootloader-external, https://nixos.org/manual/nixos/stable/#sec-bootspec

## What is EFISTUB

The Linux kernel has a built-in EFI boot stub (`CONFIG_EFI_STUB=y`) that allows booting directly via UEFI firmware — no bootloader needed. The UEFI loads the kernel as a PE/COFF executable, and the initrd is passed via kernel parameter.

**vs systemd-boot:** systemd-boot is a boot manager with a menu. EFISTUB is direct kernel boot — no menu, no selection, no intermediary.

**Official NixOS status:** NixOS does not have a built-in EFISTUB module. The official bootloaders are systemd-boot and GRUB. This document describes a custom setup using `boot.loader.external`, the NixOS mechanism for external bootloader backends (see [manual](https://nixos.org/manual/nixos/stable/#sec-bootloader-external)).

## Requirements

- UEFI system (not Legacy/BIOS)
- ESP mounted at `/boot` (vfat)
- `efibootmgr` package
- `boot.loader.efi.canTouchEfiVariables = true`
- Kernel with `CONFIG_EFI_STUB=y` (all NixOS default kernels)

## How it works on NixOS

NixOS stores boot info in a **bootspec** (`boot.json`) at each generation's toplevel ([RFC-0125](https://github.com/NixOS/rfcs/pull/125)):

```
/nix/var/nix/profiles/system → current generation (symlink)
  └── boot.json  → contains kernel, initrd, kernelParams, init paths
```

Since NixOS kernel paths change per generation (`/nix/store/...-linux-7.x/bzImage`), a script must:

1. Read `boot.json` from the current generation
2. Copy kernel + initrd to fixed paths on the ESP
3. Register/update the UEFI boot entry via `efibootmgr`

## Bootspec format (boot.json)

```json
{
  "org.nixos.bootspec.v1": {
    "system": "x86_64-linux",
    "kernel": "/nix/store/...-linux-7.x/bzImage",
    "initrd": "/nix/store/...-initrd-linux-7.x/initrd",
    "kernelParams": ["quiet", "root=...", "splash"],
    "init": "/nix/store/...-nixos-system-nixos-.../init",
    "toplevel": "/nix/store/...-nixos-system-nixos-..."
  },
  "org.nixos.specialisation.v1": {}
}
```

Key fields:
- `kernel` — Nix store path to the kernel (bzImage)
- `initrd` — Nix store path to the initrd
- `init` — path to stage-2 init inside the toplevel closure
- `kernelParams` — array of kernel command-line parameters

## Install script

The script receives the system closure path as its first argument (via `boot.loader.external.installHook`):

```bash
#!/bin/sh
# efistub-install.sh — copy kernel/initrd to ESP, register UEFI entry
# Called by NixOS with $1 = system closure path
set -euo pipefail

SYSTEM_CLOSURE="${1:-$(readlink -f /nix/var/nix/profiles/system)}"
ESP="/boot"
NIXOS_DIR="$ESP/EFI/nixos"
BOOTSPEC="$SYSTEM_CLOSURE/boot.json"

if [ ! -f "$BOOTSPEC" ]; then
  echo "error: bootspec not found at $BOOTSPEC" >&2
  exit 1
fi

mkdir -p "$NIXOS_DIR"

# Read bootspec via jq
kernel="$(jq -r '."org.nixos.bootspec.v1".kernel' "$BOOTSPEC")"
initrd="$(jq -r '."org.nixos.bootspec.v1".initrd' "$BOOTSPEC")"
params="$(jq -r '."org.nixos.bootspec.v1".kernelParams | join(" ")' "$BOOTSPEC")"
init="$(jq -r '."org.nixos.bootspec.v1".init' "$BOOTSPEC")"

# Append initrd secrets if available (same logic as systemd-boot builder)
initrd_secrets="$(jq -r '."org.nixos.bootspec.v1".initrdSecrets // empty' "$BOOTSPEC")"
if [ -n "$initrd_secrets" ] && [ -x "$initrd_secrets" ]; then
  cp -f "$initrd" "$NIXOS_DIR/initrd.efi"
  "$initrd_secrets" "$NIXOS_DIR/initrd.efi" || {
    echo "warning: failed to append initrd secrets, using pristine initrd" >&2
  }
else
  cp -f "$initrd" "$NIXOS_DIR/initrd.efi"
fi

# Copy kernel to ESP
cp -f "$kernel" "$NIXOS_DIR/kernel.efi"

# Build UEFI-friendly paths (backslashes, relative to ESP root)
kernel_path="\EFI\nixos\kernel.efi"
initrd_path="\EFI\nixos\initrd.efi"

# NixOS requires systemConfig= and init= parameters
efi_params="systemConfig=${SYSTEM_CLOSURE} init=${init} initrd=${initrd_path} ${params}"

# Remove old NixOS entries
old_num=$(efibootmgr | grep "NixOS" | sed 's/Boot\([0-9a-fA-F]*\).*/\1/' || true)
for num in $old_num; do
  efibootmgr -q -b "$num" -B 2>/dev/null || true
done

# Find ESP disk and partition
esp_source=$(findmnt -n -o SOURCE "$ESP")
esp_disk=$(lsblk -no PKNAME "$esp_source")
esp_part=$(lsblk -no PARTNUM "$esp_source")

# Create new entry
efibootmgr -q \
  --create --disk "/dev/$esp_disk" --part "$esp_part" \
  --label "NixOS" \
  --loader "$kernel_path" \
  --unicode "$efi_params"

# Sync ESP to disk (FAT32 is crash-unsafe)
sync

echo "EFISTUB: boot entry updated for $SYSTEM_CLOSURE"
```

## NixOS configuration

Uses `boot.loader.external`, the official mechanism for custom bootloader backends:

```nix
# Disable existing bootloaders
boot.loader.limine.enable = false;
# boot.loader.systemd-boot.enable = false;  # if using systemd-boot
# boot.loader.grub.enable = false;          # if using GRUB

# Enable external bootloader backend
boot.loader.external = {
  enable = true;
  installHook = "${pkgs.writeShellScript "efistub-install" ''
    exec ${./efistub-install.sh} "$@"
  ''}";
};

# Required for EFI variable manipulation
boot.loader.efi.canTouchEfiVariables = true;

# NixOS uses this to check kernel supports EFI boot stub
# (all default NixOS kernels have CONFIG_EFI_STUB=y)
boot.loader.supportsInitrdSecrets = true;

# efibootmgr for UEFI entry management
environment.systemPackages = [ pkgs.efibootmgr ];
```

### How `nixos-rebuild` triggers the script

The `boot.loader.external.installHook` is called by NixOS during:

- `nixos-rebuild switch` — after activation, bootloader is updated
- `nixos-rebuild boot` — bootloader is updated before next boot
- `nixos-install` — initial installation

The hook receives the new system closure path as `$1`. This means the script runs **automatically** on every rebuild, keeping the UEFI entry in sync with the current generation.

This is different from `system.activationScripts`, which only runs during `switch` and `test`, but **not** during `boot`.

## Manual UEFI entry (without script)

For initial setup or debugging:

```bash
# Create entry manually
efibootmgr --create \
  --disk /dev/nvme1n1 --part 1 \
  --label "NixOS" \
  --loader /EFI/nixos/kernel.efi \
  --unicode "systemConfig=/nix/store/...-nixos-system init=/nix/store/...-init initrd=\EFI\nixos\initrd.efi quiet splash"

# List entries
efibootmgr

# Delete entry
efibootmgr -b XXXX -B

# Set boot order
efibootmgr -o XXXX,YYYY,ZZZZ
```

## Fallback: UEFI Shell

If the system won't boot, enter UEFI Shell (usually via firmware menu) and boot manually:

```
FS0:
\EFI\nixos\kernel.efi systemConfig=/nix/store/... init=/nix/store/...-init initrd=\EFI\nixos\initrd.efi quiet
```

Or create `startup.nsh` on the ESP root for automatic fallback:

```
\EFI\nixos\kernel.efi systemConfig=/nix/store/... init=/nix/store/...-init initrd=\EFI\nixos\initrd.efi quiet
```

## Alternative: Unified Kernel Image (UKI)

UKI is the modern approach — combines kernel + initrd + cmdline into a single EFI executable. This avoids the need for separate `initrd=` parameters and works better with Secure Boot.

```bash
# Build UKI with ukify (systemd 254+)
ukify build \
  --linux /nix/store/...-linux/bzImage \
  --initrd /nix/store/...-initrd/initrd \
  --cmdline "systemConfig=... init=... quiet" \
  --output /boot/EFI/nixos/nixos.efi

# Register in UEFI
efibootmgr --create --disk /dev/nvme1n1 --part 1 \
  --label "NixOS UKI" --loader /EFI/nixos/nixos.efi
```

NixOS has experimental UKI support via `boot.uki` options (NixOS 25.05+). See [nixpkgs issue #341357](https://github.com/NixOS/nixpkgs/issues/341357) for status.

## Historical context

NixOS once had a built-in `efi-boot-stub` module ([nbp/nixos](https://github.com/nbp/nixos/blob/master/modules/installer/efi-boot-stub/efi-boot-stub.nix)) that supported direct EFISTUB booting with `efibootmgr`. It was removed when NixOS moved to the bootspec/RFC-0125 architecture. The `boot.loader.external` mechanism is its modern replacement.

## Fallback boot entry

Create a second UEFI entry for recovery (e.g. boot into single-user mode):

```bash
efibootmgr --create \
  --disk /dev/nvme1n1 --part 1 \
  --label "NixOS Fallback" \
  --loader /EFI/nixos/kernel.efi \
  --unicode "init=/nix/store/...-init initrd=\EFI\nixos\initrd.efi single"
```

## Pros and cons

| Pros | Cons |
|------|------|
| Fastest possible boot (no bootloader) | No boot menu — must use firmware or UEFI shell |
| Simple — just kernel + initrd on ESP | Cannot edit kernel params at boot time |
| No extra packages beyond efibootmgr | Not officially supported by NixOS |
| Uses official `boot.loader.external` API | `startup.nsh` fallback has hardcoded paths |

## Troubleshooting

### "EFI stub: Measured initrd data into PCR 9" then freeze

Common on some laptops (Xiaomi, Lenovo). Try adding `CONFIG_ACPI_DEBUG=y` via kernel patch:

```nix
boot.kernelPatches = [{
  name = "acpi-debug";
  patch = null;
  extraStructuredConfig = with lib.kernel; {
    ACPI_DEBUG = yes;
  };
}];
```

### Boot entry not persisting after reboot

Some firmware (notably Lenovo, Dell) loses EFI variables. Solutions:
- Use `startup.nsh` on ESP as fallback
- Use UKI instead (single file, no variables needed)
- Update BIOS firmware

### efibootmgr: EFI Variables are not supported

Check if running in Legacy/BIOS mode:

```bash
[ -d /sys/firmware/efi/efivars ] && echo "UEFI" || echo "Legacy"
```

If Legacy, EFISTUB won't work — use GRUB with `device = "nodev"` instead.

### initrd secrets not being applied

If using `boot.initrd.secrets`, verify the `initrdSecrets` field exists in bootspec:

```bash
jq '."org.nixos.bootspec.v1".initrdSecrets' /nix/var/nix/profiles/system/boot.json
```

If null, secrets are not configured. If present, ensure the script has execute permission on the secrets appender.

### `nixos-rebuild boot` doesn't update UEFI entry

This is expected if using `system.activationScripts` instead of `boot.loader.external`. The `installHook` is called by NixOS during both `switch` and `boot` actions.

## See also

- [Limine bootloader](limine.md) — previous bootloader setup
- [Kernel configuration](kernel.md) — kernel params and modules
- [NixOS Bootloader wiki](https://wiki.nixos.org/wiki/Bootloader)
- [NixOS Manual: External Bootloader Backends](https://nixos.org/manual/nixos/stable/#sec-bootloader-external)
- [NixOS Manual: Bootspec](https://nixos.org/manual/nixos/stable/#sec-bootspec)
- [Arch Wiki: EFI boot stub](https://wiki.archlinux.org/title/EFI_boot_stub)
- [Linux kernel EFI boot stub docs](https://docs.kernel.org/admin-guide/efi-stub.html)
- [RFC-0125: Bootspec](https://github.com/NixOS/rfcs/pull/125)
