{ pkgs, ... }: {
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
          gtk-theme = "Mint-L-Dark";
          icon-theme = "Numix-Circle";
        };
      };
    }
  ];
}
