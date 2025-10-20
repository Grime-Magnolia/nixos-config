{stdenv, latest, lib, pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "xdna-driver";
  version = "1.6";
  outputs = [
    "out" 
    "firmware"
  ];
  outputSpecified = true;
  setOutputFlags = true;
  src = latest.fetchgit {
    url = "https://github.com/amd/xdna-driver";
    rev = "refs/heads/${version}";
    fetchSubmodules = true;
    outputHash = "sha256-KbkoTNJWDcLC2ohzCZX/FsQDs7Hd0Oxo0OA1Q9VqJuE=";
  };
  buildInputs = with pkgs; [
    pkg-config
    libdrm
    clang 
    libusb1
    ocl-icd
    opencl-headers
    cmake
    boost
    ocamlPackages.curses
    openssl
    rapidjson
    gtest
    git
    gnumake
    doxygen
    linuxHeaders
    libuuid
    libsystemtap
    linuxPackages.systemtap
    zlib
    libelf
    latest.linuxPackages.kernel.dev
    python3Packages.pybind11
    python3
    udev
    level-zero
    sphinx
    tree
    latest.linuxHeaders
  ];
  patches = [
    ./distro-nixos.patch
    ./patch.diff
    ./amdxdna_pci_drv-patch.diff
  ];
  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DXDNA_BIN_DIR=${placeholder "out"}"
    "-DFIRMWARE_INSTALL_DIR=${placeholder "firmware"}/lib/firmware"
    "-DCMAKE_INSTALL_LIBDIR=./lib"
    "-DPYTHON_EXECUTABLE=${pkgs.python3}/bin/python3"
    "-Wno-dev"
    "-DCPACK_GENERATOR=TGZ"
    "-DXDNA_CPACK_LINUX_PKG_FLAVOR=nixos"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
  ];
  postPatch = ''
    # Patch KERNEL_SRC in amdxdna Makefile
    substituteInPlace src/driver/amdxdna/Makefile \
      --replace "KERNEL_SRC ?=" \
                "KERNEL_SRC := ${latest.linuxPackages_latest.kernel.dev}/lib/modules/${latest.linuxPackages_latest.kernel.version}/build # Patched for NixOS"
    
    echo "Replacing /lib/modules/`uname -r` references..."
    find . -type f -name Makefile | while read -r f; do
      echo "  → Patching $f"
      # Replace literal /lib/modules/`uname -r` occurrences
      substituteInPlace "$f" \
        --replace-warn "/lib/modules/\`uname -r\`" \
                  "${latest.linuxPackages_latest.kernel.dev}/lib/modules/${latest.linuxPackages_latest.kernel.version}"
    done


    substituteInPlace xrt/src/runtime_src/ert/CMakeLists.txt \
      --replace-fail 'set(ERT_INSTALL_FIRMWARE_PREFIX "/lib/firmware/xilinx")' \
      "set(ERT_INSTALL_FIRMWARE_PREFIX \"$firmware/lib/firmware/xilinx\")"


    substituteInPlace ./CMakeLists.txt \
      --replace-fail 'set(XDNA_PKG_FW_DIR   /usr/lib/firmware/amdnpu)' \
      'set(XDNA_PKG_FW_DIR   $firmware/lib/firmware/amdnpu)'
    
    substituteInPlace CMake/pkg.cmake \
    --replace-warn '\$\{AMDXDNA_BINS_DIR\}' "$out/share/amdxdna" \
    --replace-warn '\$\{XDNA_PKG_DATA_DIR\}' "$out/share/amdxdna" \

    substituteInPlace CMakeLists.txt \
    --replace-warn 'set(XDNA_BIN_DIR      /bins) # For saving all built artifacts for quick testing' "set(XDNA_BIN_DIR      $out) # For saving all built artifacts for quick testing"
    mkdir -p $out/share
    mkdir -p $firmware/lib/firmware -p
  '';
  postInstall = ''
  echo "Separating firmware and kernel module..."

  # Move firmware blobs
  mkdir -p "${placeholder "firmware"}/lib/firmware/amdxdna"
  if [ -f "$out/share/amdxdna/amdxdna.tar.gz" ]; then
    cp "$out/share/amdxdna/amdxdna.tar.gz" "${placeholder "firmware"}/lib/firmware/amdxdna/"
  elif [ -f "$out/driver/amdxdna.tar.gz" ]; then
    cp "$out/driver/amdxdna.tar.gz" "${placeholder "firmware"}/lib/firmware/amdxdna/"
  fi

  # Remove firmware from $out so it doesn't get duplicated
  rm -f "$out/share/amdxdna/amdxdna.tar.gz" || true
  rm -f "$out/driver/amdxdna.tar.gz" || true
  '';

}
