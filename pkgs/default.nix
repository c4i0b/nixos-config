# Custom Nix packages.
pkgs: {
  accela = pkgs.stdenv.mkDerivation rec {
    pname = "accela";
    version = "20260524150213";

    src = pkgs.fetchurl {
      url = "https://github.com/ciscosweater/enter-the-wired/releases/download/${version}/ACCELA-${version}-linux.tar.gz";
      hash = "sha256-G6lHo8TQYMkGSVGVhHHiFm3JlwrO8iliKWvFOUI+UcY=";
    };

    nativeBuildInputs = [ pkgs.copyDesktopItems pkgs.makeWrapper ];

    desktopItems = [
      (pkgs.makeDesktopItem {
        name = "accela";
        exec = "accela";
        icon = "accela";
        comment = "ACCELA - Steam Library Manager";
        desktopName = "ACCELA";
        categories = [ "Game" "Utility" ];
        terminal = false;
      })
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      unpack_dir="$TMPDIR/accela"
      mkdir -p "$unpack_dir" "$out/bin" "$out/share/accela" "$out/share/pixmaps"
      tar -xzf "$src" -C "$unpack_dir"

      install -Dm755 "$unpack_dir/bin/ACCELA.AppImage" "$out/share/accela/ACCELA.AppImage"
      install -Dm644 "$unpack_dir/bin/accela.png" "$out/share/pixmaps/accela.png"

      makeWrapper ${pkgs.appimage-run}/bin/appimage-run "$out/bin/accela" \
        --add-flags "$out/share/accela/ACCELA.AppImage"

      copyDesktopItems

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "ACCELA - Steam Library Manager";
      license = licenses.mit;
      platforms = platforms.linux;
      mainProgram = "accela";
    };
  };
}
