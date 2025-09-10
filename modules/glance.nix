{lib,pkgs,config,...}:
let
  cfg = config.customGlance;
in 
{
  options.customGlance = {
    enable = lib.mkEnableOption "enable glance";
  };
  config = lib.mkIf cfg.enable {
    services.glance = {
      enable = true;
      settings = {
        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "calendar";
                    first-day-of-week = "monday";
                  }
                  {
                    type = "rss";
                    limit = 10;
                    collapse-after = 3;
                    cache = "12h";
                    feeds = [
                      {
                        url = "https://selfh.st/rss/";
                        title = "selfh.st";
                        limit = 4;
                      }
                      {url = "https://ciechanow.ski/atom.xml";}
                      {
                        url = "https://www.joshwcomeau.com/rss.xml";
                        title = "Josh Comeau";
                      }
                      {url = "https://samwho.dev/rss.xml";}
                      {
                        url = "https://ishadeed.com/feed.xml";
                        title = "Ahmad Shadeed";
                      }

                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "group";
                    widgets = [
                      {
                        type = "hacker-news";
                      }
                      {
                        type = "lobsters";
                      }
                    ];
                  }
                ];
              }
              {
                size = "small";
                widgets = [
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
                  {
                    type = "releases";
                    cache = "1d";
                    repositories = [
                      "glanceapp/glance"
                      "go-gitea/gitea"
                      "immich-app/immich"
                      "syncthing/syncthing"
                    ];
                  }
                ];
              }
            ];
          }
          {
            name = "Bookmarks";
            columns = [
              {
                size = "full";
                widgets = [
                  {
                    type = "bookmarks";
                    groups = [] ++ [
                      {
                        title = "Arrstack";
                        links = [] ++ [
                          {
                            title = "Prowlarr";
                            icon = "sh:prowlarr";
                            url = "http://localhost:9696/";
                          }
                        ] ++ [
                          {
                            title = "Radarr";
                            icon = "sh:radarr";
                            url = "http://localhost:7878/";
                          }
                        ] ++ [
                          {
                            title = "Sonarr";
                            icon = "sh:sonarr";
                            url = "http://localhost:8989/";
                          }
                        ] ++ [
                          {
                            title = "Bazarr";
                            icon = "sh:bazarr";
                            url = "http://localhost:6767/";
                          }
                        ];
                      }
                    ] ++ [];
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
