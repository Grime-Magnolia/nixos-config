self: super: {
  yt-dlp = super.yt-dlp.overrideAttrs (oldAttrs: rec {
    pname = "yt-dlp";
    version = "2025.10.22";

    src = super.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = version;
      sha256 = "sha256-jQaENEflaF9HzY/EiMXIHgUehAJ3nnDT9IbaN6bDcac=";
    };
  });
}

