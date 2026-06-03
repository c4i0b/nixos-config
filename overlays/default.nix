# This file defines overlays
# These are arbitrary named and just some conventions I use, you can name then whenever and/or make as many as you want
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev:
    (import ../pkgs final.pkgs)
    // {
      # Import upstream default.nix with our pkgs (so appimage-run
      # includes zstd via the modifications overlay below).
      accela = (import "${inputs.enter-the-wired}/default.nix") { pkgs = final; };

      # SLSsteam - Steamclient Modification for Linux (LD_AUDIT injection)
      sls-steam = inputs.sls-steam.packages.${final.stdenv.hostPlatform.system}.sls-steam;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # Provide libzstd.so.1 inside the FHS env so PyQt6-based
    # AppImages (e.g. ACCELA) can resolve it at runtime.
    appimage-run = prev.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [ zstd ];
    };

    # Pop Shell: track master_noble branch via flake input
    gnomeExtensions =
      prev.gnomeExtensions
      // {
        pop-shell = prev.gnomeExtensions.pop-shell.overrideAttrs (old: {
          version = inputs.pop-shell.shortRev or inputs.pop-shell.lastModifiedDate;
          src = inputs.pop-shell;
        });

        dash-to-dock = prev.gnomeExtensions.buildShellExtension {
          pname = "dash-to-dock";
          uuid = "dash-to-dock@micxgx.gmail.com";
          name = "gnome-shell-extension-dash-to-dock";
          version = 105;
          src = prev.fetchzip {
            url = "https://extensions.gnome.org/extension-data/dash-to-dockmicxgx.gmail.com.v105.shell-extension.zip";
            sha256 = "sha256-z0oopkiOgclCA2KteVTX9YWke8c31B7Q1xMCL7BPo18=";
          };
          meta = {
            description = "A dock for the GNOME Shell";
            license = prev.lib.licenses.gpl2Plus;
          };
        };
      };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstablePkgs'
  unstable-packages = final: _prev: {
    unstablePkgs = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
