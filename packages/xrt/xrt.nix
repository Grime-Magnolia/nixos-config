{stdenv, latest, linuxPackages, linuxHeaders, lib, pkgs, linuxPackages_latest, ...}:
stdenv.mkDerivation rec {
  pname = "xrt";
  version = "202520.2.20.172";
  outputs = [
    "out" 
    "dev"
    #"driver"
    #"firmware"
  ];
  outputSpecified = true;
  setOutputFlags = true;
  src = pkgs.fetchgit {
    url = "https://github.com/Xilinx/XRT";
    rev = "${version}";
    fetchSubmodules = true;
    outputHash = "sha256-QqOJHS/vhYvol0wshiuA+mO6dGGJGLjYhR8Xq5v7x8c=";
  };
  patches = [
    ./xrt-replay.patch
    ./build-sh.patch
    ./xrt_swemu.patch
    ./common_em.patch
  ];
  env = {
    XRT_FIRMWARE_DIR="${placeholder "firmware"}/lib/firmware";
    XILINX_VITIS="${pkgs.callPackage ../vitis/vitis.nix {}}/lib";
   };
  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    gnumake
    gcc              # ensure a full gcc toolchain for configure/compiles
    libgcc
    stdenv.cc.libc.static
    binutils
    bintools
    libdrm
    libusb1
    linuxPackages.kernel.moduleBuildDependencies
    protobuf_26
    python3Packages.protobuf
    python3
    elfutils
    libffi
    strace
    pciutils
    perl
    ncurses
    lm_sensors
    gdb
    libyaml
    linux-doc
    #uclibc-ng
  ];
  buildInputs = with pkgs; [
    ocl-icd
    opencl-headers
    #uclibc-ng
    libffi
    cmake
    gdb
    perl
    libtiff
    libyaml
    ncurses
    lm_sensors
    pciutils
    boost
    ocamlPackages.curses
    ocamlPackages.pbrt
    ocamlPackages.ocaml-protoc
    strace
    openssl
    python3Packages.protobuf
    rapidjson
    gtest
    git
    gnumake
    doxygen
    libuuid
    libsystemtap
    linuxPackages.systemtap
    zlib
    libelf
    elfutils
    linuxPackages.kernel.dev
    python3Packages.pybind11
    python3
    udev
    level-zero
    protobuf_26
    curl
    linuxHeaders
    protobufc
    linux-doc
    (pkgs.callPackage ../vitis/vitis.nix {})
  ];
  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
    "-pthread"
  ];
  NIX_LDFLAGS = [
    "-L${pkgs.glibc}/lib"
  ];
  makeFlags = [
    "-C ${placeholder "out"}/driver/xocl"
  ];
  buildPhase = ''
    echo make all -j$(nproc)
    make all -j$(nproc)
  '';
  cmakeFlags = [
    "-DXRT_INSTALL_DIR=${placeholder "out"}"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_BINARY_DIR=./bin"
    "-DCMAKE_INSTALL_BINDIR=./bin"
    "-DCMAKE_INSTALL_INCLUDEDIR=./include"
    "-DCMAKE_INSTALL_LIBDIR=./lib"
    "-DPYTHON_EXECUTABLE=${pkgs.python3}/bin/python3"
    "-DCPACK_GENERATOR=TGZ"
    "-DXDNA_CPACK_LINUX_PKG_FLAVOR=nixos"
    "-DCMAKE_BUILD_TYPE=Release"
    "-DBUILD_SHARED_LIBS=ON"   # Prefer shared (.so) linking
    "-DXRT_BUILD_STATIC_EXECUTABLES=OFF"
    "-DCROSS_COMPILE=ON"
  ];
  postPatch = ''
  mkdir -p ${placeholder "out"}/driver_code
  mkdir -p ${placeholder "out"}/driver/xocl
  mkdir -p ${placeholder "out"}/driver_code/driver/include
  mkdir -p ${placeholder "out"}/driver_code/driver/xocl
  #mkdir -p ${placeholder "firmware"}/lib/firmware

   substituteInPlace src/runtime_src/core/tools/xbmgmt2/CMakeLists.txt \
  --replace-fail 'target_link_options(''${XBMGMT2_NAME}_static PRIVATE "-static" "-L''${Boost_LIBRARY_DIRS}")' \
            '# target_link_options(''${XBMGMT2_NAME}_static PRIVATE "-static" "-L''${Boost_LIBRARY_DIRS}")  # disabled for Nix'


    substituteInPlace src/runtime_src/core/tools/xbutil2/CMakeLists.txt \
      --replace-fail 'target_link_options(''${XBUTIL2_NAME}_static PRIVATE "-static" "-L''${Boost_LIBRARY_DIRS}")' \
                '# target_link_options(''${XBUTIL2_NAME}_static PRIVATE "-static" "-L''${Boost_LIBRARY_DIRS}")  # disabled for Nix'

    substituteInPlace tests/xrt/22_verify/CMakeLists.txt \
      --replace-fail 'target_link_options(''${TESTNAME}_hw_static PRIVATE "-static" "-L''${XRT_LINK_DIRS}")' \
                '# target_link_options(''${TESTNAME}_hw_static PRIVATE "-static" "-L''${XRT_LINK_DIRS}")  # disabled for Nix'

    echo "Replacing /lib/modules/`uname -r` references..."
    find . -type f -name Makefile | while read -r f; do
      echo "  → Patching $f"
      # Replace literal /lib/modules/`uname -r` occurrences
      substituteInPlace "$f" \
        --replace-warn "/lib/modules/\`uname -r\`" \
                  "${linuxPackages_latest.kernel.dev}/lib/modules/${linuxPackages_latest.kernel.version}"
    done
    substituteInPlace src/runtime_src/ert/CMakeLists.txt \
      --replace-fail 'set(ERT_INSTALL_FIRMWARE_PREFIX "/lib/firmware/xilinx")' \
      "set(ERT_INSTALL_FIRMWARE_PREFIX \"${placeholder "firmware"}/lib/firmware/xilinx\")"

    substituteInPlace src/runtime_src/core/common/aiebu/src/cpp/utils/asm/CMakeLists.txt \
      --replace 'SET(AIEBU_STATIC TRUE)' \
      'SET(AIEBU_STATIC FALSE)'
    substituteInPlace src/runtime_src/core/common/aiebu/src/cpp/utils/asm/CMakeLists.txt \
      --replace 'SET(AIEBU_LINK_STATIC TRUE)' \
      'SET(AIEBU_LINK_STATIC FALSE)'
    substituteInPlace src/runtime_src/tools/xclbinutil/CMakeLists.txt \
    --replace 'add_executable(xclbinutil' \
    'find_package(Threads REQUIRED)\nadd_executable(xclbinutil'
    substituteInPlace src/runtime_src/tools/xclbinutil/CMakeLists.txt \
      --replace 'target_link_libraries(xclbinutil' \
      'target_link_libraries(xclbinutil Threads::Threads'

    substituteInPlace src/runtime_src/tools/xclbinutil/CMakeLists.txt \
      --replace 'add_executable(xclbintest' \
      'find_package(Threads REQUIRED)\nadd_executable(xclbintest'
    substituteInPlace src/runtime_src/tools/xclbinutil/CMakeLists.txt \
      --replace 'target_link_libraries(xclbintest' \
      'target_link_libraries(xclbintest Threads::Threads'

    substituteInPlace src/runtime_src/tools/xclbinutil/CMakeLists.txt \
    --replace-fail 'add_executable(''${XCLBINUTIL_NAME} ''${XCLBINUTIL_SRCS})' \
    'add_executable(''${XCLBINUTIL_NAME} ''${XCLBINUTIL_SRCS})
set_target_properties(''${XCLBINUTIL_NAME} PROPERTIES COMPILE_FLAGS "-pthread" LINK_FLAGS "-pthread")
target_link_libraries(''${XCLBINUTIL_NAME} PRIVATE Threads::Threads)'

  # Add -pthread to xclbintest
  substituteInPlace src/runtime_src/tools/xclbinutil/CMakeLists.txt \
    --replace-fail 'add_executable(''${UNIT_TEST_NAME} ''${XCLBINTEST_SRCS})' \
    'add_executable(''${UNIT_TEST_NAME} ''${XCLBINTEST_SRCS})
set_target_properties(''${UNIT_TEST_NAME} PROPERTIES COMPILE_FLAGS "-pthread" LINK_FLAGS "-pthread")
target_link_libraries(''${UNIT_TEST_NAME} PRIVATE Threads::Threads)'
    
    substituteInPlace build/xocl_petalinux_compile/CMakeLists.txt \
      --replace-fail 'set(XRT_DKMS_INSTALL_DIR "''${CMAKE_BINARY_DIR}/../driver_code")' \
      'set(XRT_DKMS_INSTALL_DIR "${placeholder "out"}/driver_code")'

    substituteInPlace "src/CMake/dkms-edge.cmake" \
    --replace-fail 'set (XRT_DKMS_INSTALL_DIR "/usr/src/xrt-''${XRT_VERSION_STRING}")' \
    'set(XRT_DKMS_INSTALL_DIR "${placeholder "out"}/driver_code")'

    substituteInPlace src/CMake/version.cmake \
    --replace-fail 'set (XRT_DKMS_INSTALL_DIR "/usr/src/xrt-''${XRT_VERSION_STRING}")' \
    'set(XRT_DKMS_INSTALL_DIR "${placeholder "out"}/driver_code")'

    substituteInPlace src/CMake/dkms.cmake \
    --replace-fail 'set (XRT_DKMS_INSTALL_DIR "/usr/src/xrt-''${XRT_VERSION_STRING}")' \
    'set(XRT_DKMS_INSTALL_DIR "${placeholder "out"}/driver_code")'
    
    substituteInPlace build/xocl_petalinux_compile/CMakeLists.txt \
    --replace-fail 'set (XRT_INSTALL_DIR           "''${CMAKE_BINARY_DIR}")' \
    'set (XRT_INSTALL_DIR           "${placeholder "out"}")'

   substituteInPlace src/CMake/xrtVariables.cmake \
    --replace-fail 'set (XRT_INSTALL_DIR .)' 'set (XRT_INSTALL_DIR ${placeholder "out"})'
   substituteInPlace src/CMake/xrtVariables.cmake \
    --replace-fail 'set (XRT_INSTALL_DIR            .)' 'set (XRT_INSTALL_DIR            ${placeholder "out"})'
    
    substituteInPlace src/runtime_src/core/pcie/tools/xbflash.qspi/CMakeLists.txt \
      --replace-fail 'DESTINATION ''${XRT_INSTALL_DIR}/bin)' \
      "DESTINATION ${placeholder "out"}/bin)"   
    substituteInPlace src/runtime_src/core/pcie/tools/xbflash.qspi/CMakeLists.txt \
      --replace-fail 'DESTINATION ''${XBFLASH_INSTALL_DEST}' \
      'DESTINATION ${placeholder "out"}/bin'

    substituteInPlace src/runtime_src/core/tools/xbflash2/CMakeLists.txt \
    --replace-fail 'DESTINATION ''${XBFLASH_INSTALL_DEST}' \
    'DESTINATION ${placeholder "out"}'

    # Patch hardcoded install prefix
    substituteInPlace build/build.sh \
      --replace-fail '/opt/xilinx/xrt' "$out"

    # Also patch test/build scripts just to avoid `/opt` references
    grep -Rl "/opt/xilinx" . | while read -r f; do
      substituteInPlace "$f" --replace "/opt/xilinx" "$out"
    done

    substituteInPlace src/CMake/dkms-aws.cmake \
      --replace-fail 'set(XRT_DKMS_AWS_INSTALL_DIR "/usr/src/xrt-aws-''${XRT_VERSION_STRING}")' \
      'set(XRT_DKMS_AWS_INSTALL_DIR "${placeholder "out"}")'
    
    substituteInPlace src/runtime_src/tools/scripts/install.sh \
      --replace-fail '/etc/OpenCL/vendors' \
      '${placeholder "out"}/OpenCL/vendors'
    
    substituteInPlace src/CMake/cpackLin.cmake \
      --replace-fail '/etc/OpenCL/vendors' \
      '${placeholder "out"}'

    substituteInPlace src/CMake/config/postinst-edge.in \
      --replace-fail '/etc/OpenCL/vendors' \
      '${placeholder "out"}'

    substituteInPlace src/CMake/icd.cmake \
      --replace-fail '/etc/OpenCL/vendors' \
      '${placeholder "out"}'
    
    substituteInPlace build/debian/xrt-zocl-dkms.postinst \
      --replace-fail '/etc/OpenCL/vendors' \
      '${placeholder "out"}'

    echo replacing each .sh file with shabang ${pkgs.bash} instead of /bin/bash
    find . -type f -name "*.sh" | while read -r f; do
      echo "  → Patching $f"
      substituteInPlace "$f" \
        --replace-warn "#!/bin/bash" \
                  "#!${pkgs.bash}/bin/bash"
    done
    echo replacing each file that contains /usr/src and replace that with $out
    grep -rnl "/usr/src" | while read -r f; do
      echo "  → Patching $f"
      substituteInPlace "$f" \
        --replace-fail "usr/src" \
                  "$out"
    done

    mkdir -p $out/share
  '';
  postInstall = ''
    mkdir -p $out/share/licenses/xrt
    mv $out/license/LICENSE $out/share/licenses/xrt/LICENSE
    cp $out/setup.sh $out/bin
    find -type f -name "*.bin"

    rm -f $out/bin/*.bat
    rm -f $out/version.json $out/setup.csh $out/xilinx.icd
    rm -rf $out/license
  '';

}
