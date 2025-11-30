{ pkgs ,...}:

pkgs.stdenv.mkDerivation {
  name = "vitissrc";
  outputs = ["out"];
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out
    cp -r ${./vitisarchive} $out
  '';
}
