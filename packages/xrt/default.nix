let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.05";
  unstable = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  latest = import unstable { config = {}; overlays = []; };
  pkgs = import nixpkgs { config = {}; overlays = []; };
in {
  xdna-driver = pkgs.callPackage ./xdna-driver.nix {inherit latest;};
}
