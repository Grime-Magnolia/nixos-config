{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.arr;
  mkDisableOption = description:(lib.mkOption {
      default = true;
      type = lib.types.bool;
      inherit description;
    }
  );
  mkStrOption = description:(lib.mkOption {
      default = "";
      type = lib.types.str;
      inherit description;
    }
  );
  betterif = condition: list: (if condition then list else []);
in 
{
  options.arr = rec {
    # Enable options
    enable = lib.mkEnableOption "Enable the Arr module";
    homepage.enable = mkDisableOption "Enable homepage";
    sonarr = {
      enable = mkDisableOption "Enable Sonarr";
      key = mkStrOption "Sonarr key";
    };
    bazarr = {
      enable = mkDisableOption "Enable Bazarr";
      key = mkStrOption "Bazarr key";
    };
    radarr = {
      enable = mkDisableOption "Enable Radarr";
      key = mkStrOption "Radarr key";
    };
    prowlarr = {
      enable = mkDisableOption "Enable Prowlarr";
      key = mkStrOption "Prowlarr key";
    };
    jellyfin = {
      enable = mkDisableOption "Enable Jellyfin";
      key = mkStrOption "Jellyfin key";
    };
    flaresolverr.enable = mkDisableOption "Enable flaresolverr";
    transmission.enable = mkDisableOption "Enable transmission";
    jellyseerr.enable = mkDisableOption "Enable jellyseerr";
  };

  config = lib.mkIf cfg.enable {
    # Arr apps
    services = {
      prowlarr.enable = cfg.prowlarr.enable;
      flaresolverr.enable = cfg.flaresolverr.enable || cfg.prowlarr.enable;
      transmission = lib.mkIf cfg.transmission.enable {
        enable = true;
        group="arr";
      };
      sonarr = lib.mkIf cfg.sonarr.enable {
        enable = true;
        group="arr";
      };
      bazarr = lib.mkIf cfg.bazarr.enable {
        enable = true;
        group="arr";
      };
      radarr = lib.mkIf cfg.radarr.enable {
        enable = true;
        group="arr";
      };
      jellyfin = lib.mkIf cfg.jellyfin.enable {
        enable = true;
        group="arr";
      };
      jellyseerr.enable = cfg.jellyseerr.enable;
    };

    services.homepage-dashboard = lib.mkIf cfg.homepage.enable {
      enable = true;
      allowedHosts = "localhost:8082,127.0.0.1:8082";
      widgets = [
        {
          datetime = {
            text_size = "xl";
            format = {
              dateStyle = "short";
              timeStyle = "short";
              hour12 = true;
            };
          };
        }
        {
          resources = {
            cpu = true;
            disk = "/";
            memory = true;
            refresh = 5000;
            network = true;
            uptime = true;
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];
      services = [] ++ (betterif (cfg.sonarr.enable || cfg.radarr.enable || cfg.bazarr.enable) [{
          "*Arr" = [] ++ (betterif cfg.sonarr.enable [
              {
                "Sonarr" = {
                  description = "Download and manage tv shows";
                  href = "http://localhost:8989/";
                  widget = {
                    type = "sonarr";
                    url = "http://localhost:8989";
                    key = cfg.sonarr.key;
                  };
                };
              }
            ]) ++ (betterif cfg.radarr.enable [
              {
                "Radarr" = {
                  description = "Download and manage movies";
                  href = "http://localhost:7878/";
                  widget = {
                    type = "radarr";
                    url = "http://localhost:7878/";
                    key = cfg.radarr.key;
                  };
                };
              }
            ]) ++ (betterif cfg.bazarr.enable [
              {
                "Bazarr" = {
                  description = "Download and manage subtitles";
                  href = "http://localhost:6767/";
                  widget = {
                    type = "bazarr";
                    url = "http://localhost:6767/";
                    key = cfg.bazarr.key;
                  };
                };
              }
            ]);
          }]) ++ (betterif (cfg.transmission.enable || cfg.prowlarr.enable) [
          {
            "Downloader" = [] ++ (betterif cfg.transmission.enable [
                {
                  "Transmission" = {
                    description = "Torrent downloader";
                    href = "http://localhost:9091/";
                    widget = {
                      type = "transmission";
                      url = "http://localhost:9091";
                      username = "";
                      password = "";
                    };
                  };
                }
              ]) ++ (betterif cfg.prowlarr.enable [
                {
                  "Prowlarr" = {
                    description = "Torrent indexer";
                    href = "http://localhost:9696/";
                    widget = {
                      type = "prowlarr";
                      url = "http://localhost:9696/";
                      key = cfg.prowlarr.key;
                    };
                  };
                }
            ]);
          }
      ]) ++ (betterif (cfg.jellyfin.enable || cfg.jellyseerr.enable) [
        {
          "Jellyfin" = []
            ++ (betterif cfg.jellyfin.enable [
              {
                "Jellyfin" = {
                  description = "Jellyfin Media Server";
                  href = "http://localhost:8096/";
                };
              }
            ])
            ++ (betterif cfg.jellyseerr.enable [
              {
                "Jellyseerr" = {
                  description = "A requests manager for Jellyfin";
                  href = "http://localhost:5055/";
                };
              }
            ]);
        }
      ]);
    };
  };
}
