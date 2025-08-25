{ config, pkgs, lib, inputs, ... }:

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
  };

  config = lib.mkIf config.homepage.enable {
    services.homepage-dashboard = {
      enable = true;
      allowedHosts = "localhost:8082,127.0.0.1:8082";
      settings = {
        "*Arr" = {
          style = "row";
          columns = 3;
        };
      };
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
      services = [
        {
          "*Arr" = [
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
          ];
        }
        {
          "Downloader" = [
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
          ];
        }
        {
          "Jellyfin" = [
            {
              "Jellyfin" = {
                description = "Jellyfin Media Server";
                href = "http://localhost:8096/";
              };
            }
            {
              "Jellyseerr" = {
                description = "A requests manager for Jellyfin";
                href = "http://localhost:5055/";
              };
            }
          ];
        }
      ];
    };
  };
}

