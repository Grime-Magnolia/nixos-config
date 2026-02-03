self: super: {
  yt-dlp = super.yt-dlp.overrideAttrs (oldAttrs: rec {
    pname = "yt-dlp";
    version = "2026.01.31";

    src = super.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = version;
      sha256 = "sha256-Em8FLcCizSfvucg+KPuJyhFZ5MJ8STTjSpqaTD5xeKI=";
    };
  });
}

