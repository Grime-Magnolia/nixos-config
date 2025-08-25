# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  nix = {
    package = pkgs.nixVersions.stable;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  homepage = {
    enable = true;
    sonarrkey = "d062b5c87d324705a46c84a2e9aa73c9";
    prowlarrkey = "d912f445b19b4741ad79b83a5e89176a";
    radarrkey = "5c5bc76e359e445a8030fc63e26c580b";
    bazarrkey = "84a99e34c9d2a458aeba019956509747";
  };
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "amdgpu" "kfd" ];
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"       # or lz4 if you prefer faster compression
    "zswap.max_pool_percent=20"   # Max RAM percent zswap uses
  ];
  boot.kernel.sysctl."vm.swappiness" = 5;  # Range: 0 (avoid swap) to 100 (prefer swap)

  # Auto upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";

  # Networking stuff
  networking.hostName = "Tynix"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  
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


  system.activationScripts.myst-symlink.text = ''
    ln -sf ${pkgs.bash}/bin/bash /bin/
    ln -sf ${pkgs.less}/bin/less /bin/
    ln -sf ${pkgs.sudo}/bin/sudo /bin/
  '';
  # *Arr stack
  services = {
    transmission.enable = true;
    fwupd.enable = true;
    transmission.group="arr";
    prowlarr.enable = true;
    flaresolverr.enable = true;
    sonarr.enable = true;
    sonarr.group="arr";
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
  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp58s0";
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
  programs.nix-ld.enable = true;
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
  #networking.useDHCP = true;
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
  services.udev.extraRules = ''
    KERNEL=="kfd", GROUP="video", MODE="0660"
    KERNEL=="renderD*", GROUP="video", MODE="0660"
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.desktopManager.retroarch.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.arr.members = ["bazarr" "jellyfin" "lidarr" "radarr" "sonarr" "transmission" "tygo"];
  users.users.ollama = {
    isSystemUser = true;
    group = "ollama";
    extraGroups = [ "video" "render" ];
  };
  users.users.tygo = {
    isNormalUser = true;
    description = "Tygo";
    extraGroups = [ "networkmanager" "input" "wheel" "video" "render"];
    shell = pkgs.fish;
    packages = with pkgs; [
      # Games
      alpaca
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
      tuba
      fractal
      protontricks
      handbrake
      wvkbd
      gnome-calculator
      blender
      sublime4
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
      hyprpolkitagent
      mpv
      opencpn
      kitty
    ];
  };

  services.xserver.desktopManager.kodi.enable = true;
  # Ollama
  services.ollama = {
    enable = true;
    loadModels = [ "llama3.2:3b" "deepseek-r1:8b" "qwen2.5-coder:7b"];
    rocmOverrideGfx = "10.3.0";
    acceleration = "rocm";
    environmentVariables = {
      HCC_AMDGPU_TARGET = "10.3.0"; # used to be necessary, but doesn't seem to anymore
    };
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
  swapDevices = [
    {
      device = "/swapfile";
      size = 16384;  # size in MB = 16GB
    }
  ];
  environment.systemPackages = with pkgs; [
    wget
    rocmPackages.rocm-smi
    rocmPackages.rocminfo
    rocmPackages.clr
    rocmPackages.rocm-device-libs
    rocmPackages.amdsmi
    rocmPackages.rocthrust
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

  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
