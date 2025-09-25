self: super: {
  yt-dlp = super.yt-dlp.overrideAttrs (oldAttrs: rec {
    pname = "yt-dlp";
    version = "2024.09.22";

    src = super.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = version;
      sha256 = "REPLACE_ME_WITH_PREFETCHED_HASH";
    };
  });
}

