{ config, lib, pkgs, ... }:
let
  noctaliaPkg = pkgs.unstablePkgs.noctalia-shell;

  noctaliaConfigFile = pkgs.writeText "noctalia-settings.json" (builtins.toJSON {
    bar = {
      position = "top";
      density = "compact";
      showCapsule = false;
      widgets = {
        left = [
          {
            id = "Workspaces";
          }
          {
            id = "WindowTitle";
          }
        ];
        center = [
          {
            id = "Clock";
          }
        ];
        right = [
          {
            id = "Network";
          }
          {
            id = "Bluetooth";
          }
          {
            id = "Volume";
          }
          {
            id = "Tray";
          }
          {
            id = "Battery";
          }
        ];
      };
    };
    theme = {
      scheme = "catppuccin-mocha";
    };
    wallpaper = {
      type = "color";
      color = "#1e1e2e";
    };
  });
in {
  environment.systemPackages = [ noctaliaPkg ];

  system.activationScripts.noctalia-config = lib.mkAfter ''
    if [ ! -f /home/caio/.config/noctalia-shell/settings.json ]; then
      mkdir -p /home/caio/.config/noctalia-shell
      cp ${noctaliaConfigFile} /home/caio/.config/noctalia-shell/settings.json
      chown caio:users /home/caio/.config/noctalia-shell/settings.json
    fi
  '';
}
