{pkgs,lib,stdenv,fetchurl,bash,...}:
let
  file = fetchurl {
    url = "https://amd-ax-dl.entitlenow.com/dl/ul/2025/05/31/R212730247/FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145_Lin64.bin?hash=LuPN1cIwFdAaEMgyqgbYLw&expires=1763413377&filename=FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145_Lin64.bin";
    sha256 = "sha256-vKpzOJPkXjO2aQjZil5S1+T+QIwuCaJUgqmrb7qiN2M=";
  };
 
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "vitis";
  version = "2025.1";

  dontUnpack = true;

  nativeBuildInputs = with pkgs;[
    tree
  ];
  buildInputs = with pkgs; [
    coreutils
    patchelf
    glibc
    glibc.static
    jdk24
  ];
  prePatch = ''
  mkdir -p fakebin
  ln -s ${pkgs.coreutils}/bin/* fakebin/
  export PATH=$PWD/fakebin:$PATH

  cp ${file} installer.bin
  chmod +x installer.bin
  ./installer.bin --noexec --target extracted
  '';
  patches = [

  ];
  postPatch = ''
  find . -type f -exec grep -Il "^#!/bin/" {} \;| while read -r f; do
    echo "  → Patching $f"
    substituteInPlace "$f" \
      --replace-warn "/bin/bash" \
                "${bash}/bin/bash"
  done
  substituteInPlace extracted/bin/setup-boot-loader.sh \
    --replace-warn '"''${root}/bin/ldlibpath.sh"' \
    '"sh ''${root}/bin/ldlibpath.sh"'
  '';
  
  installPhase = ''
  cd extracted
  #export X_JAVA_HOME=${pkgs.jdk24}
  export X_CLASS_PATH=$(printf "%s:" lib/classes/*.jar)
  export LD_LIBRARY_PATH=$(printf "%s:" lib/*.o)   # native libs

  ${pkgs.jdk24}/bin/java \
    -cp "$X_CLASS_PATH" \
    -Dlogback.configurationFile=data/logback.xml \
    com.xilinx.installer.api.InstallerLauncher \
    --agree XilinxEULA,3rdPartyEULA \
    -b Add \
    -p Vitis \
    -e "Vitis Unified Software Platform" \
    --location $out 2>/dev/null|tail -n 2|head -n 1 > config.txt

  ${pkgs.jdk24}/bin/java \
    -cp "$X_CLASS_PATH" \
    -Dlogback.configurationFile=data/logback.xml \
    com.xilinx.installer.api.InstallerLauncher \
    --agree XilinxEULA,3rdPartyEULA \
    -b Install \
    -p Vitis \
    -e "Vitis Unified Software Platform" \
    -c config.txt \
    --location $out
  '';

  meta = {
    description = "";
    homepage = "https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vitis.html";
  };
})
