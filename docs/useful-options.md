# Useful NixOS Options Reference

Common configuration options for daily use.

## Security

```nix
# OpenSSH server
services.openssh.enable = true;

# Firewall (default: allow all on loopback, deny others)
networking.firewall.enable = true;
networking.firewall.allowedTCPPorts = [ 22 80 443 ];
networking.firewall.allowedUDPPorts = [ ];

# Tailscale VPN
services.tailscale.enable = true;
```

## Development

```nix
# Docker
virtualisation.docker.enable = true;
users.users.caio.extraGroups = [ "docker" ];

# Podman (rootless)
virtualisation.podman.enable = true;
virtualisation.podman.dockerCompat = true;

# QEMU/KVM
virtualisation.libvirtd.enable = true;
programs.virt-manager.enable = true;
```

## Bluetooth

```nix
hardware.bluetooth.enable = true;
hardware.bluetooth.powerOnBoot = true;
services.blueman.enable = true;
```

## Power Management

```nix
# TLP for laptops
services.tlp.enable = true;

# Auto-cpufreq
services.auto-cpufreq.enable = true;

# CPU microcode
hardware.cpu.intel.updateMicrocode = true;  # or amd
```

## Fonts

```nix
fonts.packages = with pkgs; [
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  liberation_ttf
  fira-code
  fira-code-symbols
  (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
];
```

## Printing & Scanning

```nix
# CUPS with auto-discover
services.printing.enable = true;
services.printing.drivers = [ pkgs.brlaser ];  # Brother laser drivers

# Scanner
hardware.sane.enable = true;
hardware.sane.extraBackends = [ pkgs.sane-airscan ];
```

## Logind (session/ACPI handling)

```nix
services.logind.extraConfig = ''
  HandlePowerKey=lock
  HandleLidSwitch=ignore
'';

services.logind.lidSwitch = "ignore";
services.logind.lidSwitchExternalPower = "ignore";
```

## Useful system packages

```nix
environment.systemPackages = with pkgs; [
  # CLI
  git
  curl
  wget
  htop
  btop
  neovim
  tmux
  tree
  jq
  ripgrep
  fd

  # System
  pciutils          # lspci
  usbutils          # lsusb
  lm_sensors        # sensors
  dmidecode         # hardware info
  file
  unzip
  xz
  zip

  # Network
  dig               # dnsutils
  iperf3
  traceroute
  netcat
  nmap              # only for authorized scanning
];
```

## Nix tuning

```nix
# Binary cache auto-trust
nix.settings.trusted-users = [ "root" "caio" ];

# More parallelism for builds
nix.settings.max-jobs = 4;
nix.settings.cores = 8;

# Auto-optimise (deduplicate store)
nix.optimise.automatic = true;

# Number of generations to keep
boot.loader.systemd-boot.configurationLimit = 10;
```
