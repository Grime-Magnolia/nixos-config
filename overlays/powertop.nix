self: super: {
  powertop = super.powertop.overrideAttrs (oldAttrs: rec {
    pname = "powertop";
    version = "latest";

    src = super.fetchFromGitHub {
      owner = "fenrus75";
      repo = "powertop";
      rev = "master";
      sha256 = "sha256-OrDhavETzXoM6p66owFifKXv5wc48o7wipSypcorPmA=";
    };
    nativeBuildInputs = old.nativeBuildInputs ++ [ pkgs.pkg-config pkgs.libtracefs ];
    buildInputs = old.buildInputs ++ [ pkgs.libtracefs ];
  });
}

