final: prev: {
  freac = prev.stdenv.mkDerivation rec {
    pname = "freac";
    version = "1.1.7";
    src = prev.fetchFromGitHub {
      owner = "enzo1982";
      repo = "freac";
      rev = "v${version}";
      sha256 = "sha256-bHoRxxhSM7ipRkiBG7hEa1Iw8Z3tOHQ/atngC/3X1a4=";
    };
    buildInputs = with prev; [
      boca
      smooth
      systemd
      wrapGAppsHook3
      flac
      lame
      libogg
      libvorbis
      opusfile
      fdk_aac
    ];
    makeFlags = [
      "prefix=$(out)"
    ];
    installPhase = ''
      mkdir -p $out/bin
      mkdir -p $out/include
      cp include $out/include -r
      cp bin/freac $out/bin/
      wrapProgram $out/bin/freac \
        --prefix LD_LIBRARY_PATH : ${prev.lib.makeLibraryPath [ prev.flac prev.smooth prev.boca ]}
    '';
    meta = with prev.lib; {
      description = "Audio converter and CD ripper with support for various popular formats and encoders";
      license = licenses.gpl2Plus;
      homepage = "https://www.freac.org/";
      maintainers = with maintainers; [ shamilton ];
      platforms = platforms.linux;
    };
  };
}
