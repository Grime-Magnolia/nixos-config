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
    ] ++ [
      {
        name = "School";
        columns = [
          {
            size = "small";
            widgets = [] ++ [
              {
                type = "to-do";
              }
              {
                type = "rss";
                title = "Itslearning updates";
                feeds = [
                  {
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=16519&PersonId=425076&CustomerId=2630&Guid=47b99fffd61f943e2bdaadb3cfb17975&Culture=nl-NL";
                    title = "Klas 4-5-6 Info 25-26";
                  }
                  {
                    title = "la5.schk2-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15428&PersonId=425076&CustomerId=2630&Guid=fbe0535cb45be21468ecd0732db9baa8&Culture=nl-NL";
                  }
                  {
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15426&PersonId=425076&CustomerId=2630&Guid=f333e8a1d446cacc103839d143765e9a&Culture=nl-NL";
                    title = "la5.biol2-25-26";
                  }
                  {
                    title = "la5.men3_nkoo-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15425&PersonId=425076&CustomerId=2630&Guid=8d00b0a5058ea3d915d8154302f8328d&Culture=nl-NL";
                  }
                  {
                    title = "la5.wisd1-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15423&PersonId=425076&CustomerId=2630&Guid=442ed42b3e04e4633058f26386b167a8&Culture=nl-NL";
                  }
                  {
                    title = "la5.wisb1-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15414&PersonId=425076&CustomerId=2630&Guid=070402d4d979ff70a5133bda4914ee0c&Culture=nl-NL";
                  }
                  {
                    title = "la5.entl5a-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15410&PersonId=425076&CustomerId=2630&Guid=21eab3be768323ae92f746f0e032a253&Culture=nl-NL";
                  }
                  {
                    title = "la5.netl5a-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15409&PersonId=425076&CustomerId=2630&Guid=f455ddc482c706b3ca8f5c70449e88ff&Culture=nl-NL";
                  }
                  {
                    title = "la5.o&o5a-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15403&PersonId=425076&CustomerId=2630&Guid=128f26b9ba7d6c38d1be0b1a4b0c1908&Culture=nl-NL";
                  }
                  {
                    title = "la5.nat1-25-26";
                    url = "https://pj.itslearning.com/Dashboard/NotificationRss.aspx?LocationType=1&LocationID=15399&PersonId=425076&CustomerId=2630&Guid=d75fa011ca0126190612b38db1e706ef&Culture=nl-NL";
                  }
                ];
              }
            ];
          }
          {
            size = "full";
            widgets = [] ++ [
              {
                type = "monitor";
                title = "Communicatie";
                sites = [] ++ [
                  {
                    title = "Itslearning";
                    url = "https://pj.itslearning.com/";
                    icon = "https://itslearning.com/hubfs/itslearning-app-square.svg";
                  }
                  {
                    title = "Somtoday";
                    url = "https://leerling.somtoday.nl/";
                    icon = "https://somtoday-servicedesk.zendesk.com/hc/theming_assets/01HZPJD0ESAB114ENQ1FD6EDHR";
                  }
                  {
                    title = "Profielx.nu";
                    url = "https://www.profielx.nu/site/home.php";
                    allow-insecure = true;
                    alt-status-codes = [301];
                  }
                  {
                    title = "Zermelo";
                    url = "https://ovofn.zportal.nl/";
                    icon = "https://ovofn.zportal.nl/static/v/25.09j48/img/zermelo2013.svg";
                  }
                  {
                    title = "MijnPrintcode";
                    url = "https://mijnprintcode.ovofn.nl/login/tenant_1";
                  }
                  {
                    title = "MobilePrinting";
                    url = "https://mobileprinting.ovofn.nl:9443/end-user/ui/login";
                    icon = "https://mobileprinting.ovofn.nl:9443/end-user/ui/assets/img/favicon.ico";
                  }
                  {
                    title = "Wachtwoordherstel";
                    url = "http://wachtwoordherstel.ovofn.nl/";
                  }
                  {
                    title = "Laptop herstel";
                    url = "https://ovofn.topdesk.net/solutions/open-knowledge-items/item/KI%200207/nl/";
                  }
                ];
              }
            ];
          }
          {
            size = "small";
            widgets = [
              {
                type = "monitor";
                title = "Methodes";
                sites = [
                  {
                    title = "Biologie voor jou MAX boek + online havo/vwo bovenbouw 5 vwo 4 jaar afname";
                    url = "https://toegang.malmberg.nl/content?ean=9789402046793";
                    icon = "https://bvj.secure.malmberg.nl/images/favicons/120.png";
                  }
                  {
                    title = "Moderne Wiskunde ed 12.1 vwo B 3 FLEX boek + online";
                    url = "https://toegang.noordhoff.nl/9789001055141";
                    icon = "https://apps.noordhoff.nl/se/apple-touch-icon-120x120-precomposed.png";
                  }
                  {
                    title = "Moderne Wiskunde ed 12.1 vwo B 4 FLEX boek + online";
                    url = "https://toegang.noordhoff.nl/9789001055158";
                    icon = "https://apps.noordhoff.nl/se/apple-touch-icon-120x120-precomposed.png";
                  }
                  {
                    title = "Newton LRN-line online + boek 5 vwo 4-jaar afname";
                    url = "https://toegang.thiememeulenhoff.nl/9789006391398";
                    icon = "https://d2pdrtet7r0o77.cloudfront.net/v218/assets/favicon.ico";
                  }
                  {
                    title = "Polaris scheikunde leerlinglicentie aanvullend havo/vwo/gym bovenbouw";
                    url = "https://toegang.boomvoortgezetonderwijs.nl/9789464421132";
                    icon = "https://boomdigitaal.nl/assets/favicons/default/128x128.png";
                  }
                ];
              }
            ];
          }
        ];
      }
    ];
  };
}
