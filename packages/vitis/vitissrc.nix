{ pkgs ,...}:

pkgs.stdenv.mkDerivation {
  name = "vitissrc";
  outputs = ["out"];
  src = /home/tygo/vitisarchive;
  dontUnpack = true;
  outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  buildCommand = ''
    mkdir -p $out
    cp -r $src $out
  '';
}
