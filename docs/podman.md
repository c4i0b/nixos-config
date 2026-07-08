# Podman — Official NixOS Wiki

Source: https://wiki.nixos.org/wiki/Podman

## Setup

```nix
virtualisation.containers.enable = true;
virtualisation.podman = {
  enable = true;
  dockerCompat = true;
  defaultNetwork.settings.dns_enabled = true;
};

users.users.<USERNAME>.extraGroups = [ "podman" ];
```

Security: podman group membership is equivalent to root.

## Tips

### podman-compose

Providers: `docker-compose` or `podman-compose`. Set via:

```nix
services.podman.settings.containers.compose_providers = [ "/path/to/provider" ];
```

### Cross-architecture

```nix
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
boot.binfmt.preferStaticEmulators = true;
```

### Containers as systemd services

```nix
virtualisation.oci-containers.backend = "podman";
virtualisation.oci-containers.containers."name" = {
  image = "image";
  autoStart = true;
  ports = [ "127.0.0.1:1234:1234" ];
};
```

### DevContainers registry

```nix
virtualisation.containers.registries.search = [ "docker.io" ];
```
