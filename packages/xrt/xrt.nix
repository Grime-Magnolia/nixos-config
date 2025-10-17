{stdenv,lib,pkgs}:
stdenv.mkDerivation let 
  version = "202510.2.19.194";
in {
  pname = "xrt";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "Xilinx";
    repo = "XRT";


  };
}
