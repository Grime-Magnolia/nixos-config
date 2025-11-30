{pkgs,lib,stdenv,fetchurl,bash,...}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "vitis";
  version = "2025.1";
  src = /home/tygo/vitisarchive;
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
  '';
  patches = [

  ];
  installPhase = ''
  cd $src
  pwd
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
    --location $out 2>/dev/null|tail -n 2|head -n 1 > /tmp/config.txt || true

  ${pkgs.jdk24}/bin/java \
    -cp "$X_CLASS_PATH" \
    -Dlogback.configurationFile=data/logback.xml \
    com.xilinx.installer.api.InstallerLauncher \
    --agree XilinxEULA,3rdPartyEULA \
    -b Install \
    -p Vitis \
    -e "Vitis Unified Software Platform" \
    -c /tmp/config.txt \
    --location $out
  '';
  postInstall = ''
    find $out -xtype l -exec rm -v {} +
  '';
  dontCheckForBrokenSymlinks = true;

  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  outputHash = "";

  meta = {
    description = "";
    homepage = "https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vitis.html";
  };
})
