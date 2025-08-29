{ stdenv, ... }:

let
  version = "1.35.4";
  url = "https://github.com/mysteriumnetwork/node/releases/download/${version}/myst_linux_amd64.tar.gz";
  sha256 = "0xbfjxqj6gy501a0qwsh4mn6lvnvxzyyzk8jkndwqwhcc2r0j6wi"; # you will need to fill this in
in
stdenv.mkDerivation {
  pname = "mystnode";
  inherit version;

  src = builtins.fetchTarball {
    inherit url sha256;
  };
  installPhase = ''
    mkdir $out/bin -p
    cp myst myst_supervisor $out/bin
  '';
}
