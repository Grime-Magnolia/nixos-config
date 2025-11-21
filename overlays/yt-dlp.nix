self: super: {
  yt-dlp = super.yt-dlp.overrideAttrs (oldAttrs: rec {
    pname = "yt-dlp";
    version = "2025.11.12";

    src = super.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = version;
      sha256 = "sha256-Em8FLcCizSfvucg+KPuJyhFZ5MJ8STTjSpqaTD5xeKI=";
    };
  });
}

