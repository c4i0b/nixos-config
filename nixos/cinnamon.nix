{ pkgs, ... }:
let
  inherit (pkgs.lib.gvariant) mkTuple;
in {
  services.xserver.desktopManager.cinnamon.enable = true;

  environment.cinnamon.excludePackages = with pkgs; [
    celluloid
  ];

  environment.sessionVariables.GTK_IM_MODULE = "xim";

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/cinnamon/desktop/interface" = {
          font-name = "CaskaydiaCove Nerd Font 11";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Numix-Circle";
        };

        "org/cinnamon/theme" = {
          name = "Mint-Y-Dark-Red";
        };

        "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
          font = "Cascadia Mono 12";
          use-system-font = false;
        };
      };
    }
  ];
}
