# Testing NixOS Config in a VM

Source: https://wiki.nixos.org/wiki/NixOS:nixos-rebuild_build-vm

## Commands

```bash
# Build QEMU VM (boots directly into kernel/initrd)
sudo nixos-rebuild build-vm

# Build QEMU VM using the actual bootloader (Limine, GRUB, etc.)
sudo nixos-rebuild build-vm-with-bootloader
```

After building, run the VM:

```bash
./result/bin/run-<hostname>-vm
```

## Prerequisite: test user

Add a temporary user for VM login (passwords from host are not carried over):

```nix
users.users.nixosvmtest = {
  isSystemUser = true;
  initialPassword = "test";
  group = "nixosvmtest";
};
users.groups.nixosvmtest = {};
```

## Configure VM resources

```nix
virtualisation.vmVariant = {
  virtualisation = {
    memorySize = 2048;   # 2 GB RAM
    cores = 3;           # 3 CPU cores
  };
};
```

Use `vmVariantWithBootloader` if building with `build-vm-with-bootloader`.

## Troubleshooting

- After changing config, delete the `$hostname.qcow2` file in the current directory before rebuilding
- Default VM has 1 CPU and 1024 MiB memory — may be too small for desktop environments

## Quick syntax check (no VM build)

```bash
nix-instantiate '<nixpkgs/nixos>' -A system
```

Or check option values without building:

```bash
nix repl --file '<nixpkgs/nixos>'
nix-repl> config.environment.systemPackages
```
