# Linux Kernel — NixOS Reference

Official docs: https://wiki.nixos.org/wiki/Linux_kernel
Manual: https://nixos.org/manual/nixos/stable/#sec-kernel-config

## Active in current config
- `boot.kernelPackages = unstable.linuxPackages_latest` — latest mainline from unstable
- `boot.kernelParams = [ "quiet" "rd.udev.log_level=3" "rd.systemd.show_status=auto" "mglru=on" ]`
- All other kernel options use NixOS defaults

## Selecting a kernel

```nix
boot.kernelPackages = pkgs.linuxPackages_latest;  # latest mainline
boot.kernelPackages = pkgs.linuxPackages;          # default (LTS)
boot.kernelPackages = pkgs.linuxPackages_hardened; # security-hardened
boot.kernelPackages = pkgs.linuxPackages_zen;      # Zen kernel (desktop-tuned)
```

Available kernels: `linuxPackages`, `linuxPackages_latest`, `linuxPackages_hardened`,
`linuxPackages_zen`, `linuxPackages_xanmod`, `linuxPackages_lqx`, etc.

## Kernel parameters (command line)

```nix
boot.kernelParams = [
  "quiet"                          # reduce boot spam
  "rd.udev.log_level=3"            # quieter initrd
  "rd.systemd.show_status=auto"    # status only on error
  "mglru=on"                       # Multi-Gen LRU (better page reclaim)
];
```

## Kernel modules

```nix
# Stage 2 modules (loaded after rootfs is mounted)
boot.kernelModules = [ "vhost_net" "tun" ];

# Initrd modules (loaded early, before rootfs)
boot.initrd.kernelModules = [ ];

# Blacklist modules
boot.blacklistedKernelModules = [ "pcspkr" ];
```

## Sysctl tuning

```nix
boot.kernel.sysctl = {
  "vm.vfs_cache_pressure" = 50;       # keep dentry/inode caches longer
  "vm.dirty_ratio" = 10;              # max dirty pages % before blocking
  "vm.dirty_background_ratio" = 5;    # start writeback at this %
};
```

## Custom kernel config

```nix
nixpkgs.config.packageOverrides = pkgs: {
  linux_6_6 = pkgs.linux_6_6.override {
    extraConfig = ''
      KGDB y
      PREEMPT y
    '';
  };
};
```

## CachyOS-style tweaks (replicable on NixOS)

CachyOS applies these at the kernel build level (patches, LTO, PGO). On stock
NixOS we can replicate some via sysctl and kernel params:

### Networking — BBR congestion control
```nix
boot.kernel.sysctl = {
  "net.core.default_qdisc" = "fq";
  "net.ipv4.tcp_congestion_control" = "bbr";
};
```
BBR3 is patched in CachyOS — not available on stock kernel without custom build.

### I/O schedulers (via udev)
```nix
services.udev.extraRules = ''
  # NVMe: no scheduler (none) — lowest latency
  ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
  # SSD: mq-deadline
  ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  # HDD: bfq
  ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
'';
```

### MGLRU (Multi-Gen LRU)
Available upstream since 6.1. Enable via kernel param:
```nix
boot.kernelParams = [ "mglru=on" ];
```

### Preemption (full)
CachyOS uses PREEMPT_DYNAMIC with full preemption. On modern kernels this is
the default for desktop configs. Verify with:
```bash
cat /sys/kernel/debug/sched/preempt
# Should show: full
```

### Timer frequency
CachyOS uses 1000Hz (desktop). Stock NixOS kernel may use 250Hz. To verify:
```bash
zcat /proc/config.gz | grep CONFIG_HZ
```
Changing this requires a custom kernel build.

### Transparent Hugepages
CachyOS defaults to `always`. NixOS default is `madvise` (safer).
```nix
boot.kernelParams = [ "transparent_hugepage=always" ];
```

## Verifying current kernel
```bash
uname -r
zcat /proc/config.gz | grep -E 'CONFIG_HZ_|CONFIG_PREEMPT|CONFIG_NO_HZ'
cat /sys/kernel/debug/sched/preempt
sysctl vm.swappiness
sysctl net.ipv4.tcp_congestion_control
```
