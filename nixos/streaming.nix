# Game streaming: Sunshine host for Moonlight clients.
{pkgs, ...}: let
  steam = pkgs.unstablePkgs.steam;

  steam-close = pkgs.writeShellScript "sunshine-steam-close" ''
    export PATH="${pkgs.procps}/bin:${pkgs.coreutils}/bin"
    pkill -f ".local/share/Steam/ubuntu12_32/steam"
  '';

  steam-bigpicture = pkgs.writeShellScript "sunshine-steam-bigpicture" ''
    exec ${pkgs.util-linux}/bin/setsid \
      ${pkgs.util-linux}/bin/setpriv \
        --ambient-caps=-all \
        --inh-caps=-all \
        ${steam}/bin/steam steam://open/bigpicture
  '';
in {
  services.sunshine = {
    enable = true;
    openFirewall = true;
    capSysAdmin = true;
    autoStart = true;
    settings = {
      virtual_sink = "Steam Streaming Speakers";
      system_tray = "disabled";
    };
    applications = {
      apps = [
        {
          name = "Steam Big Picture";
          detached = ["${steam-bigpicture}"];
          image-path = "steam.png";
          prep-cmd = [
            {
              do = "${pkgs.ddcutil}/bin/ddcutil setvcp 10 0";
              undo = "${pkgs.ddcutil}/bin/ddcutil setvcp 10 60";
            }
            {
              do = "${pkgs.systemd}/bin/loginctl lock-session";
              undo = "";
            }
            {
              do = "";
              undo = "${steam-close}";
            }
          ];
        }
      ];
    };
  };
}
