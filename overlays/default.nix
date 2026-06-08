# This file defines overlays
# These are arbitrary named and just some conventions I use, you can name then whenever and/or make as many as you want
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev:
    (import ../pkgs final.pkgs)
    // {
      # Import upstream default.nix with our pkgs.
      accela = final.callPackage "${inputs.enter-the-wired}/default.nix" { };

      # SLSsteam - Steamclient Modification for Linux (LD_AUDIT injection)
      sls-steam = inputs.sls-steam.packages.${final.stdenv.hostPlatform.system}.sls-steam;
    };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # If ACCELA fails with missing libs, check its logs
    # (~/.local/share/ACCELA/logs/) or run via terminal to see the error,
    # then add the missing package here:
    #   appimage-run = prev.appimage-run.override {
    #     extraPkgs = pkgs: with pkgs; [ xcb-util-cursor zstd icu ];
    #   };

    # Pop Shell: track master_noble branch via flake input
    gnomeExtensions =
      prev.gnomeExtensions
      // {
        pop-shell = prev.gnomeExtensions.pop-shell.overrideAttrs (old: {
          version = inputs.pop-shell.shortRev or inputs.pop-shell.lastModifiedDate;
          src = inputs.pop-shell;
        });
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
