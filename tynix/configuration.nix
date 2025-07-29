# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
     # ./modules
    ];
  
  nix = {
    package = pkgs.nixVersions.stable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Auto upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";

  # Networking stuff
  networking.hostName = "Tynix"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.useDHCP = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.connectionCheck = {
    enable = true;
    uri = "http://nmcheck.gnome.org/check_network_status.txt";
  };
  
  # Printing
  services.printing.enable = true;
  services.printing.webInterface = false;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; }; # Force intel-media-driver
  hardware.graphics = { # hardware.graphics since NixOS 24.11
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
      intel-ocl
    ];
  };
  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
  services.printing.drivers = [pkgs.hplip ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  system.activationScripts.myst-symlink.text = ''
    ln -sf ${pkgs.bash}/bin/bash /bin/
    ln -sf ${pkgs.less}/bin/less /bin/
    ln -sf ${pkgs.sudo}/bin/sudo /bin/
  '';
  # *Arr stack
  services = {
    transmission.enable = true;
    transmission.group="arr";
    prowlarr.enable = true;
    flaresolverr.enable = true;
    sonarr.enable = true;
    sonarr.group="arr";
    lidarr.enable = true;
    lidarr.group="arr";
    bazarr.enable = true;
    bazarr.group="arr";
    radarr.enable = true;
    radarr.group = "arr";
    jellyfin.enable = true;
    jellyfin.group = "arr";
    jellyseerr.enable = true;
    resolved.enable = true;
    libinput.enable = true;
  };
  programs.fish.enable = true;
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.steam.gamescopeSession.args = [
    "--expose-wayland"
  ];
  systemd.services.mullvaddaemon = {
    wantedBy = ["default.target"];
    requiredBy = ["network.target"];
    after = ["network.target"];
    description = "Mullvad daemon starter";
    serviceConfig = {
      ExecStart = "${pkgs.mullvad-vpn}/bin/mullvad-daemon";
    };
  };
  services.homepage-dashboard = {
    enable = true;
    allowedHosts = "localhost:8082,127.0.0.1:8082";
    services = [
      {
        "*Arr" = [
          {
            "Lidarr" = {
              description = "Download and manage music";
              href = "http://localhost:8686/";
            };
          }
          {
            "Sonarr" = {
              description = "Download and manage tv shows";
              href = "http://localhost:8989/";
            };
          }
          {
            "Radarr" = {
              description = "Download and manage movies";
              href = "http://localhost:7878/";
            };
          }
          {
            "Bazarr" = {
              description = "Download and manage subtitles";
              href = "http://localhost:6767/";
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
            };
          }
          {
            "Prowlarr" = {
              description = "Torrent indexer";
              href = "http://localhost:9696/";
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

  
  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_NL.UTF-8";
    LC_IDENTIFICATION = "nl_NL.UTF-8";
    LC_MEASUREMENT = "nl_NL.UTF-8";
    LC_MONETARY = "nl_NL.UTF-8";
    LC_NAME = "nl_NL.UTF-8";
    LC_NUMERIC = "nl_NL.UTF-8";
    LC_PAPER = "nl_NL.UTF-8";
    LC_TELEPHONE = "nl_NL.UTF-8";
    LC_TIME = "nl_NL.UTF-8";
  };
  
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;
  services.xserver.excludePackages = [pkgs.xterm];
  virtualisation.waydroid.enable = true;
  # enable gfs and udisks2
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.upower.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    noto-fonts-emoji
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    nerd-fonts.caskaydia-cove
  ];
  fonts.fontDir.enable = true;
  services.power-profiles-daemon.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.gnome.core-apps.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    decibels
    epiphany
    gnome-characters
    gnome-contacts
    gnome-font-viewer
    gnome-logs
    gnome-maps
    gnome-music
    gnome-weather
    gnome-connections
    simple-scan
    snapshot
    yelp
  ];
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  #services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.desktopManager.retroarch.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hans = {
    hashedPassword = "$y$j9T$XDb7Vak51u1Iv6dztqczH.$W8bppSbbEhP6SmxPvj0w7rIrEe7vY/RL8jOxzKIbkFD";
    isNormalUser = true;
    description = "Pappie";
    extraGroups = ["networkmanager"];
    packages = with pkgs; [
    ];
  };
  users.groups.arr.members = ["bazarr" "jellyfin" "lidarr" "radarr" "sonarr" "transmission" "tygo"];
  users.users.tygo = {
    isNormalUser = true;
    description = "Tygo";
    extraGroups = [ "networkmanager" "input" "wheel" "video"];
    shell = pkgs.fish;
    packages = with pkgs; [
      # Games
      gamemode
      godot
      steam-devices-udev-rules
      superTuxKart
      dualsensectl
      pcsx2
      vkd3d
      vulkan-tools
      protonplus
      dxvk
      #retroarch-full
      winetricks
      cava
      nixos-generators
      protontricks
      handbrake
      wvkbd
      # Image and Video management
      freetube
      libinput-gestures
      wtype
      xdotool
      helvum
      avizo
      rofi
      rkdeveloptool
      recordbox
      pavucontrol
      obs-studio
      papers
      lutris
      bitwarden-desktop
      wireguard-tools
      libnotify
      gphoto2
      audacity
      gimp
      iotas
      planify
      ffmpeg_6-full
      ffsubsync
      mullvad-vpn
      signal-desktop
      cartridges
      eww
      gamescope
      firefox
      opencpn
      kitty
    ];
  };

  services.xserver.desktopManager.kodi.enable = true;
  # Ollama
  services.ollama = {
    enable = true;
    package = unstable.ollama;
    user = "ollama";
    group = "ollama";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Hyprland apps
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  programs.localsend.enable = true;

  environment.systemPackages = with pkgs; [
    wget
    neovim
    papers
    vlc
    fish
    hyprpaper
    swww
    lm_sensors
    htop
    gimp
    krita
    inkscape
    sudo
    tldr
    baobab
    nautilus
    python312
    python312Packages.gphoto2
    waybar
    gnumake
    libreoffice
    librewolf
    networkmanagerapplet
    gnome-disk-utility
    snixembed
    paper-gtk-theme
    less
    more
    loupe
    wl-clipboard
    stow
    paper-icon-theme
    tree
    fastfetch
    #go
    #go-swagger
    rose-pine-hyprcursor
    git
    bluez
    starship
    zoxide
    eog
    fzf
    gcc
    clang
    cmake
    ninja
    #libgcc
    swaynotificationcenter
    haskellPackages.build
    gnome-text-editor
  ];

  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  xdg.portal.config.common.default = "gtk";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  services.tlp = {
        enable = false;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  
          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 20;

         #Optional helps save long term battery health
         START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
         STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging

        };
  };
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
