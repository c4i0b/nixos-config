# NVIDIA + Gaming Setup Reference

This NixOS config uses:
- `hardware.nvidia.open = true` – open-source kernel module (nvidia-open)
- `hardware.nvidia.branch = "latest"` – tracks newest driver branch (production or new feature)
- `hardware.graphics.enable32Bit = true` – required for Steam/Wine/Proton
- `programs.steam.enable = true` – enables Steam + extra Steam-related packages
- `programs.gamemode.enable = true` – enables the gamemode daemon
- Lutris, Wine, Winetricks, GOverlay, MangoHud installed as system packages

## External resources

- NixOS NVIDIA wiki: https://nixos.wiki/wiki/Nvidia
- NixOS Steam wiki: https://nixos.wiki/wiki/Steam
- NixOS Gaming page: https://nixos.wiki/wiki/Gaming
- Lutris on NixOS: https://nixos.wiki/wiki/Lutris
- MangoHud docs: https://github.com/flightlessmango/MangoHud
- Gamemode docs: https://github.com/FeralInteractive/gamemode

## Notes

- `nvidiaSettings = true` adds the NVIDIA control panel GUI (`nvidia-settings`)
- `powerManagement.enable` allows the GPU to be powered down when unused
- `modesetting.enable` enables the DRM KMS modesetting driver
- Flatpak complements Steam (Flathub has many games & launchers)
- If `nvidia-open` has issues on your GPU, set `open = false` to use proprietary modules
