{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.homepage;
in 
{
  options = {
    homepage.enable = lib.mkEnableOption "Enable the homepage dashboard module";

    homepage.sonarrkey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Sonarr API key";
    };

    homepage.radarrkey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Radarr API key";
    };

    homepage.bazarrkey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Bazarr API key";
    };

    homepage.prowlarrkey = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Prowlarr API key";
    };
    homepage.Jellyfin = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enables Jellyfin";
    };
    homepage.Jellyseerr = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enables Jellyseerr";
    };
    homepage.Radarr = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enables Radarr";
    };
    homepage.Sonarr = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enables Sonarr";
    };
    homepage.Bazarr = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enables Bazarr";
    };
    homepage.Transmission = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enables Transmission";
    };
    homepage.Prowlarr = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enables Prowlarr";
    };
  };

  config = lib.mkIf config.homepage.enable with lib; {
    #services.prowlarr = mkIf
    services.homepage-dashboard = {
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
      services = [] ++ (if (cfg.Sonarr || cfg.Radarr || cfg.Bazarr) then [{
          "*Arr" = [] ++ (if cfg.Sonarr then [
              {
                "Sonarr" = {
                  description = "Download and manage tv shows";
                  href = "http://localhost:8989/";
                  widget = {
                    type = "sonarr";
                    url = "http://localhost:8989";
                    key = config.homepage.sonarrkey;
                  };
                };
              }
            ] else []) ++ (if cfg.Radarr then [
              {
                "Radarr" = {
                  description = "Download and manage movies";
                  href = "http://localhost:7878/";
                  widget = {
                    type = "radarr";
                    url = "http://localhost:7878/";
                    key = config.homepage.radarrkey;
                  };
                };
              }
            ] else []) ++ (if cfg.Bazarr then [
              {
                "Bazarr" = {
                  description = "Download and manage subtitles";
                  href = "http://localhost:6767/";
                  widget = {
                    type = "bazarr";
                    url = "http://localhost:6767/";
                    key = config.homepage.bazarrkey;
                  };
                };
              }
            ] else []);
          }] else []) ++ (if (cfg.Transmission || cfg.Prowlarr) then [
          {
            "Downloader" = [] ++ (if cfg.Transmission then [
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
              ] else []) ++ (if cfg.Prowlarr then [
                {
                  "Prowlarr" = {
                    description = "Torrent indexer";
                    href = "http://localhost:9696/";
                    widget = {
                      type = "prowlarr";
                      url = "http://localhost:9696/";
                      key = config.homepage.prowlarrkey;
                    };
                  };
                }
            ] else []);
          }
      ] else []) ++ (if (cfg.Jellyfin || cfg.Jellyseerr) then [
        {
          "Jellyfin" = []
            ++ (if cfg.Jellyfin then [
              {
                "Jellyfin" = {
                  description = "Jellyfin Media Server";
                  href = "http://localhost:8096/";
                };
              }
            ] else [])
            ++ (if cfg.Jellyseerr then [
              {
                "Jellyseerr" = {
                  description = "A requests manager for Jellyfin";
                  href = "http://localhost:5055/";
                };
              }
            ] else []);
        }
      ] else []);
    };
  };
}
