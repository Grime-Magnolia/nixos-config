self: super: {
  powertop = super.powertop.overrideAttrs (old: {
    pname = "powertop";
    version = "master";

    src = super.fetchFromGitHub {
      owner = "fenrus75";
      repo = "powertop";
      rev = "master";
      sha256 = "sha256-OrDhavETzXoM6p66owFifKXv5wc48o7wipSypcorPmA=";
    };

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
      super.pkg-config
      super.gettext
      super.autoconf
      super.automake
      super.libtool
      super.autoconf-archive
    ];

    buildInputs = (old.buildInputs or []) ++ [
      super.libtracefs
      super.libtraceevent
      super.ncurses
    ];

    # Let the standard configurePhase handle PKG_CONFIG_PATH
    configureFlags = (old.configureFlags or []) ++ [
      "--prefix=$out"
    ];
  });
}

