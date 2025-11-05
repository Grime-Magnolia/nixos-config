{stdenv, latest, lib, pkgs, unstable, ...}:
let
  pythonEnv = pkgs.python3.withPackages(ps: [ ]);
  custompkgs.puccinialin = (pkgs.python3Packages.buildPythonPackage rec {
    pname = "puccinialin";
    version = "0.1.5";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      tag = "v${version}";
      owner = "konstin";
      fetchSubmodules = true;
      repo = "puccinialin";
      sha256 = "sha256-53BlVaEvv6ur1OtVryKF1xvybI+gGmvBDdymh4PwUdc=";
    };
    propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
      custompkgs.setuptools-rust
      hatchling
      httpx
      platformdirs
      tqdm
    ];
  });

  custompkgs.maturin = (pkgs.python3Packages.buildPythonPackage rec {
    env.MATURIN_OFFLINE_BUILD = "1";
    dontCheck = true;
    doCheck = false;
    pname = "maturin";
    version = "1.9.5";
    format = "pyproject";
    outputs = ["out" "tmp"];
    env.HOME = "${placeholder "tmp"}";
    src = pkgs.fetchFromGitHub {
      tag = "v${version}";
      owner = "PyO3";
      fetchSubmodules = true;
      repo = "maturin";
      sha256 = "sha256-2WiQtNuhuCJfKIoRKNFaX50Jah4nn2aqlAGrRq/+kww=";
    };
    patches = [
      ./pyproject.patch
    ];
    propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
      custompkgs.setuptools-rust
      custompkgs.puccinialin
    ];
    nativeBuildInputs = with pkgs; with pkgs.python3Packages; [
      rustc
      cargo
      pkg-config
      wheel
    ];
    cargoDeps = pkgs.fetchCrate {
      pname = "maturin";
      version = "1.9.6";
      sha256 = "sha256-G426Fj7FkVS7gicPK+/6DnLtuRk2LvdRw2XDbyUXTB4=";
    };
  });

  custompkgs.accelerate = (pkgs.python3Packages.buildPythonPackage rec {
    pname = "accelerate";
    version = "1.6.0";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      tag = "v${version}";
      owner = "huggingface";
      fetchSubmodules = true;
      repo = "accelerate";
      sha256 = "sha256-AsqAki79NaXJGUOEXndbWn1qpL5R4LoL+MBLfJIrMU8=";
    };
    propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
      safetensors
      numpy
      psutil
      pyyaml
      torch
      huggingface-hub
      setuptools
    ];
  });
  custompkgs.click = (pkgs.python3Packages.buildPythonPackage rec {
    pname = "click";
    version = "8.2.1";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      tag = "${version}";
      owner = "pallets";
      fetchSubmodules = true;
      repo = "click";
      sha256 = "sha256-3FfLKwpfkiGfY2+H2fQoZwLBqfPlV46xw2Bc4YEsyps=";
    };
    propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
      flit-core
    ];
  });
custompkgs.pydantic-core = (pkgs.python3Packages.buildPythonPackage rec {
    pname = "pydantic-core";
    version = "2.27.2";
    format = "pyproject";
    env.HOME = "/tmp";
    postPatch = ''
    cp ${custompkgs.maturin}/tmp /tmp
    '';
    src = pkgs.fetchFromGitHub {
      tag = "v${version}";
      owner = "pydantic";
      fetchSubmodules = true;
      repo = "pydantic-core";
      sha256 = "sha256-dGef0WflrjktAxukT8TEZhq1mrkXjcz5UE7FNQ0RINU=";
    };
    nativeBuildInputs = [
      custompkgs.maturin
    ];
    propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
      safetensors
      numpy
      psutil
      pyyaml
      torch
      huggingface-hub
      setuptools
      custompkgs.maturin
    ];
  });
  custompkgs.pydantic = (pkgs.python3Packages.buildPythonPackage rec {
    pname = "pydantic";
    version = "2.10.6";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      tag = "v${version}";
      owner = "pydantic";
      fetchSubmodules = true;
      repo = "pydantic";
      sha256 = "sha256-vkXvHQ5ipcLfx4qJKY6J4rKXCAfP2rj88GnwGMjM2go=";
    };
    propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
      safetensors
      numpy
      psutil
      pyyaml
      torch
      huggingface-hub
      setuptools
      hatchling
      hatch-fancy-pypi-readme
      custompkgs.pydantic-core
      annotated-types
    ];
  });
  custompkgs.setuptools-rust = (pkgs.python3Packages.buildPythonPackage rec {
    pname = "setuptools-rust";
    version = "1.12.0";
    format = "pyproject";
    src = pkgs.fetchFromGitHub {
      tag = "v${version}";
      owner = "PyO3";
      fetchSubmodules = true;
      repo = "setuptools-rust";
      sha256 = "sha256-31P2HIT4ShFqufgEtyE+FRh5OYuGO1SmgeHQX+su1pI=";
    };
    propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
      setuptools
      setuptools-scm
      semantic-version
    ];
  });
in
pkgs.python3Packages.buildPythonPackage rec {
  pname = "mergekit";
  version = "v0.1.4";
  format = "pyproject";
  outputSpecified = true;
  setOutputFlags = true;
  env = {
    HOME = "/tmp";
  };
  src = pkgs.fetchgit {
    url = "https://github.com/arcee-ai/mergekit";
    rev = "${version}";
    fetchSubmodules = true;
    outputHash = "sha256-OvRd5sCCQwqgntlXTSL6PkTkxTj742YlCfbgUXvCaeQ=";
  };
  propagatedBuildInputs = with pkgs; with pkgs.python3Packages; [
    pythonEnv
    setuptools
    torch
    tqdm
    custompkgs.click
    custompkgs.accelerate
    custompkgs.pydantic
    safetensors
    accelerate
    pydantic
    immutables
    transformers
    tokenizers
    huggingface-hub
    peft
    sentencepiece
    scipy
    datasets
  ];
}
