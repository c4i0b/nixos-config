{pkgs, ...}: {
  virtualisation = {
    docker.enable = true;
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
