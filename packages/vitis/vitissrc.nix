{ stdenv }:

stdenv.mkDerivation {
  name = "vitissrc";

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp ${./vitisarchive} $out
  '';
}
