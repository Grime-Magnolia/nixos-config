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
    glance.enable = mkDisableOption "Enable Glance";
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
      glance.enable = true;
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
    services.glance.settings.pages = [] ++ [
      {
        name = "Home";
        columns = [] ++ [
          {
            size = "small";
            widgets = [] ++ [
              {
                type = "calendar";
                first-day-of-week = "monday";
              }
            ] ++ [
              {
                type = "rss";
                limit = 10;
                collapse-after = 3;
                cache = "12h";
                feeds = [] ++ [
                  {
                    url = "https://selfh.st/rss/";
                    title = "selfh.st";
                    limit = 4;
                  }
                ] ++ [
                  {url = "https://ciechanow.ski/atom.xml";}
                ] ++ [
                  {
                    url = "https://www.joshwcomeau.com/rss.xml";
                    title = "Josh Comeau";
                  }
                ] ++ [
                  {url = "https://samwho.dev/rss.xml";}
                ] ++ [
                  {
                    url = "https://ishadeed.com/feed.xml";
                    title = "Ahmad Shadeed";
                  }
                ];
              }
            ];
          }
        ] ++ [
          {
            size = "full";
            widgets = [
              {
                type = "group";
                widgets = [
                  {
                    type = "hacker-news";
                  }
                ] ++ [
                  {
                    type = "lobsters";
                  }
                ];
              }
            ];
          }
        ] ++ [
          {
            size = "small";
            widgets = [] ++ [
              {
                type = "server-stats";
                servers = [
                  {
                    type = "local";
                    name = "Local";
                    cpu-temp-sensor = "coretemp-isa-0000";
                  }
                ];
              }
            ] ++ [
              {
                type = "releases";
                cache = "12h";
                repositories = [] ++ [
                  "glanceapp/glance"
                ] ++ [
                  "go-gitea/gitea"
                ] ++ [
                  "immich-app/immich"
                ] ++ [
                  "syncthing/syncthing"
                ];
              }
            ] ++ [
              {
                type = "monitor";
                title = "Services";
                sites = [] ++ (betterif (cfg.prowlarr.enable) [{
                    title = "Prowlarr";
                    icon = "sh:prowlarr";
                    url = "http://localhost:9696/";
                  }]) ++ (betterif cfg.radarr.enable [
                  {
                    title = "Radarr";
                    icon = "sh:radarr";
                    url = "http://localhost:7878/";
                  }
                  ]) ++ (betterif cfg.sonarr.enable [
                    {
                      title = "Sonarr";
                      icon = "sh:sonarr";
                      url = "http://localhost:8989/";
                    }
                  ]) ++ (betterif cfg.bazarr.enable [
                    {
                      title = "Bazarr";
                      icon = "sh:bazarr";
                      url = "http://localhost:6767/";
                    }
                  ]) ++ (betterif cfg.transmission.enable [
                    {
                      title = "Transmission";
                      icon = "sh:transmission";
                      url = "http://localhost:9091/";
                    }
                  ]);
              }
            ];
          }
        ];
      }
    ] ++ [];
  };
}
