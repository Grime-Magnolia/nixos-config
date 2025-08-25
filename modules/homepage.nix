{ config, pkgs, inputs, ...}:
{
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
                key = "95fd7478053e47dd89102aead48908da";
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
                key = "28e25bce8551464bade6724c6da60b0f";
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
                key = "2c63ca8ebb624ae5f7df78e41a33023d";
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
                url = "http:///localhost:9091";
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
                  key = "f56dc9fb89c54c60b7e8745b63add9c5";

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
              description = "a requests manager for Jellyfin";
              href = "http://localhost:5055/";
            };
          }
        ];
      }
    ];
  };
}
