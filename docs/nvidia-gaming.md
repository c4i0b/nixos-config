# NVIDIA + Gaming Setup Reference

This NixOS config uses:
- `hardware.nvidia.open = true` – open-source kernel module (nvidia-open)
- `hardware.nvidia.modesetting.enable = true` – DRM KMS modesetting (required for Wayland)
- `hardware.nvidia.powerManagement.enable = true` – GPU power-down when unused
- `hardware.nvidia.nvidiaSettings = true` – NVIDIA control panel GUI (`nvidia-settings`)
- `hardware.graphics.enable32Bit = true` – required for Steam/Wine/Proton
- `boot.kernelPackages = unstable.linuxPackages_latest` – kernel + NVIDIA drivers from unstable channel (610.43.02)
- `programs.steam.enable = true` – enables Steam + extra Steam-related packages
- `programs.gamemode.enable = true` – enables the gamemode daemon
- Lutris, Wine, Winetricks, GOverlay, MangoHud installed as system packages

## External resources

- NixOS NVIDIA wiki: https://wiki.nixos.org/wiki/Nvidia
- NixOS Steam wiki: https://wiki.nixos.org/wiki/Steam
- NixOS Gaming page: https://wiki.nixos.org/wiki/Gaming
