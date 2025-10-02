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
    readarr = {
      enable = mkDisableOption "Enable Readarr";
      key = mkStrOption "Readarr key";
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
    #transmission.package = lib.mkOption {
    #  default = pkgs.transmission_4;
    #  description = "Transmission package";
    #  type = lib.types.derivation;
    #};
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
        package = pkgs.transmission_4;
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
      readarr = lib.mkIf cfg.readarr.enable {
        enable = true;
        group = "arr";
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
        head-widgets = [
          {
            type = "search";
            search-engine = "duckduckgo";
          }
        ];
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
                  ]) ++ [
                    {
                      title = "Readarr";
                      icon = "sh:readarr";
                      url = "http://localhost:8787/";
                    }
                  ] ++ (betterif cfg.transmission.enable [
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
        name = "Nix";
        columns = [
          {
            size = "full";
            widgets = [
              { 
                type = "bookmarks";
                groups = [
                  {
                    title = "Offcial";
                    links = [
                      {
                        title = "Nix Manual";
                        url = "https://nix.dev/manual/nix";
                        icon = "si:nixos";
                      }
                      { 
                        title = "Homepage";
                        url = "https://nixos.org/";
                        icon = "si:nixos";
                      }
                      {
                        title = "Wiki";
                        url = "https://wiki.nixos.org/";
                        icon = "si:nixos";
                      }
                      {
                        title = "Search";
                        url = "https://search.nixos.org";
                        icon = "si:nixos";
                      }
                    ];
                  }
                  {
                    title = "Unofficial";
                    links = [
                      {
                        title = "Noogle";
                        url = "https://noogle.dev/";
                        icon = "si:nixos";
                      }
                      { 
                        icon = "si:github";
                        url = "https://github.com/nix-community/awesome-nix";
                        title = "Awsome Nix";
                      }
                    ];
                  }
                ];
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
            ];
          }
          {
            size = "full";
            widgets = [] ++ [
              {
                type = "group";
                widgets = [
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
                  {
                    type = "monitor";
                    title = "tools";
                    sites = [
                      {
                        title = "Outlook";
                        url = "https://outlook.office.com/";
                        icon = "https://outlook.office.com/mail/favicon.ico";
                      }
                      {
                        title = "Word";
                        url = "https://word.cloud.microsoft";
                        icon = "https://res.cdn.office.net/files/fabric-cdn-prod_20240610.001/assets/brand-icons/product/svg/word_16x1.svg";
                      }
                      {
                        title = "Powerpoint";
                        url = "https://powerpoint.cloud.microsoft";
                        icon = "https://res.cdn.office.net/files/fabric-cdn-prod_20240610.001/assets/brand-icons/product/svg/powerpoint_16x1.svg";
                      }
                      {
                        title = "Excel";
                        url = "https://excel.cloud.microsoft";
                        icon = "https://res.cdn.office.net/files/fabric-cdn-prod_20240610.001/assets/brand-icons/product/svg/excel_16x1.svg";
                      }
                      {
                        title = "Onenote";
                        url = "https://m365.cloud.microsoft/launch/onenote";
                        icon = "https://res-1.cdn.office.net/officeonline/o/s/h9E1DA5BF71513549_resources/1033/FavIcon_OneNote.ico";
                      }
                      {
                        title = "Anna's archive";
                        url = "https://annas-archive.org/";
                        icon = "https://annas-archive.org/apple-touch-icon.png?hash=d2fa3410fb1ae23ef0ab";
                      }
                    ];
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
