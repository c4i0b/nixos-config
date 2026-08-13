# Optional SSH server (my.services.ssh.enable).
{ lib, config, pkgs, ... }:
let
  cfg = config.my.services.ssh;
in
{
  options.my.services.ssh.enable = lib.mkEnableOption "SSH server";

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };
}
