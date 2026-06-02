{pkgs, ...}: {
  users.users = {
    caio = {
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII36LvhYgcFFJgpr3/lrnD7z/zp0EKBn2HFUep/0DiEZ"
      ];
      extraGroups = ["wheel" "docker" "libvirtd" "kvm" "audio" "video" "input" "networkmanager"];
    };
  };
}
