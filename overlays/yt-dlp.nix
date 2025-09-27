self: super: {
  yt-dlp = super.yt-dlp.overrideAttrs (oldAttrs: rec {
    pname = "yt-dlp";
    version = "2025.09.26";

    src = super.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = version;
      sha256 = "sha256-/uzs87Vw+aDNfIJVLOx3C8RyZvWLqjggmnjrOvUX1Eg=";
    };
  });
}

