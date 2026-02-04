{stdenv, latest, lib, pkgs, unstable, ...}:
pkgs.python3Packages.buildPythonPackage rec {
  pname = "meshcore_py";
  version = "2.2.1";
  format = "pyproject";
  src = pkgs.fetchFromGitHub {
    tag = "v${version}";
    owner = "meshcore-dev";
    fetchSubmodules = true;
    repo = "meshcore_py";
    sha256 = "sha256-Qjwi7JrSyk5wWM63OdFykB850+hquWDD9p4fZFfbI70=";
  };
  propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
    hatchling
    bleak
    pycayennelpp
    pyserial-asyncio
  ];
}
