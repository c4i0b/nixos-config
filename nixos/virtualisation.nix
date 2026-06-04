# Virtualisation: containers and VMs.
{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.lazydocker
    pkgs.podman-desktop
  ];

  virtualisation = {
    # docker.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    vmware.host = {
      enable = true;
      package = pkgs.unstablePkgs.vmware-workstation;
      extraConfig = ''
        mks.gl.allowUnsupportedDrivers = "TRUE"
        mks.vk.allowUnsupportedDevices = "TRUE"
        prefvmx.minVmMemPct = "100"
      '';
    };
  };
}
