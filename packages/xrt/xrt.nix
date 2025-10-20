{stdenv, latest, lib, pkgs, ...}:
stdenv.mkDerivation rec {
  pname = "xrt";
  version = "202520.2.20.172";
  outputs = [
    "out" 
    "firmware"
  ];
  outputSpecified = true;
  setOutputFlags = true;
  src = latest.fetchgit {
    url = "https://github.com/Xilinx/XRT";
    rev = "${version}";
    fetchSubmodules = true;
    outputHash = "sha256-QqOJHS/vhYvol0wshiuA+mO6dGGJGLjYhR8Xq5v7x8c=";
  };
  #NIX_CFLAGS_COMPILE = "-isystem ${pkgs.glibc.dev}/include -isystem ${pkgs.glibc.dev}/include/x86_64-linux-gnu";
  #NIX_LDFLAGS = "-L${pkgs.glibc}/lib";
  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    gnumake
    gcc              # ensure a full gcc toolchain for configure/compiles
    stdenv.cc.libc.static
    binutils
    bintools
    libdrm
    libusb1
  ];
  buildInputs = with pkgs; [
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
    protobuf
    curl
    latest.linuxHeaders
  ];
  NIX_CFLAGS_COMPILE = [
    "-pthread"
    "-isystem ${stdenv.cc.cc.lib}/include"
    "-isystem ${stdenv.cc.cc.lib}/include/x86_64-linux-gnu"
  ];
  NIX_LDFLAGS = [
    "-L${pkgs.glibc}/lib"
  ];

  cmakeFlags = [
    "-DXRT_INSTALL_DIR=${placeholder "out"}"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DCMAKE_BINARY_DIR=${placeholder "out"}/bin"
    "-DFIRMWARE_INSTALL_DIR=${placeholder "firmware"}/lib/firmware"
    "-DCMAKE_INSTALL_LIBDIR=./lib"
    "-DPYTHON_EXECUTABLE=${pkgs.python3}/bin/python3"
    "-DCPACK_GENERATOR=TGZ"
    "-DXDNA_CPACK_LINUX_PKG_FLAVOR=nixos"
    "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
    "-DENABLE_AZURE=OFF"
    "-DBUILD_SHARED_LIBS=ON"   # Prefer shared (.so) linking
    "-DXRT_BUILD_STATIC_EXECUTABLES=OFF"
    "-DXRT_STATIC_BUILD=OFF"
  ];
  postPatch = ''
    mkdir -p ${placeholder "out"}/driver_code
    mkdir -p ${placeholder "out"}/driver_code/driver/include
    mkdir -p ${placeholder "out"}/driver_code/driver/xocl
    echo "Patching CMake static linking directives..."

    # Disable -static flags that break linking on Nix
    #substituteInPlace src/runtime_src/core/pcie/tools/xbflash.qspi/CMakeLists.txt \
    #  --replace-fail 'target_link_options(''${XBFLASH_NAME_NEW} PRIVATE "-static")' \
    #            '# target_link_options(''${XBFLASH_NAME_NEW} PRIVATE "-static")  # disabled for Nix'

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
                  "${latest.linuxPackages_latest.kernel.dev}/lib/modules/${latest.linuxPackages_latest.kernel.version}"
    done

    substituteInPlace src/runtime_src/ert/CMakeLists.txt \
      --replace-fail 'set(ERT_INSTALL_FIRMWARE_PREFIX "/lib/firmware/xilinx")' \
      "set(ERT_INSTALL_FIRMWARE_PREFIX \"$out/lib/firmware/xilinx\")"

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
    
    #substituteInPlace src/runtime_src/core/tools/xbtracer/script/ch_mangled/CMakeLists.txt \
    #--replace-fail 'set(XRT_INSTALL_DIR ''${CMAKE_CURRENT_BINARY_DIR})' \
    #'set(XRT_INSTALL_DIR ${placeholder "out"})'

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



    mkdir -p $out/share
    mkdir -p $firmware/lib/firmware -p
    mkdir -p $out/lib/firmware -p
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
    
    cp ${placeholder "out"}/${placeholder "out"}/* $out -r
    mv $out/license/LICENSE $out/share/licenses/xrt/LICENSE
    mv $out/xbflash2 $out/bin/
    mv $out/python/* $out/lib/python3.x/site-packages/xrt/
    rm -rf $out/nix
    rm -f $out/version.json $out/setup.sh $out/setup.csh
    # Remove firmware from $out so it doesn't get duplicated
    rm -f "$out/share/amdxdna/amdxdna.tar.gz" || true
    rm -f "$out/driver/amdxdna.tar.gz" || true
    rm -rf $out/driver_code
  '';

}
