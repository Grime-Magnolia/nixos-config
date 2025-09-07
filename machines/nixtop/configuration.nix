# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, unstable, inputs, ... }:

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
  # homepage-dashboard
  arr = {
    enable = true;
    sonarr.key = "95fd7478053e47dd89102aead48908da";
    prowlarr.key = "a61160856c3242dc9fb17332d0c814fa";
    radarr.key = "28e25bce8551464bade6724c6da60b0f";
    bazarr.key = "2c63ca8ebb624ae5f7df78e41a33023d";
  };
  customGlance = {
    enable = true;
  };
  general.enable = true;
  # Swap
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16*1024; # 16 GB
  }];
  zramSwap.enable = true;
  
  # Auto updates
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--print-build-logs"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
  # Remove garbage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=lz4" # compression algorithm
    "zswap.max_pool_percent=50" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
  # Networking stuff
  networking.hostName = "nixtop"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;
  # Printing
  services.printing.enable = true;
  services.printing.webInterface = false;
  services.printing.drivers = [pkgs.hplip ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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


  system.activationScripts.myst-symlink.text = ''
    ln -sf ${pkgs.bash}/bin/bash /bin/
    ln -sf ${pkgs.less}/bin/less /bin/
    ln -sf ${pkgs.sudo}/bin/sudo /bin/
  '';
  # *Arr stack
  services = {
    fwupd.enable = true;
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

  # Fingerprint shit
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  services.fprintd = {
    enable = true;
  }; 

  fonts.fontDir.enable = true;
  services.power-profiles-daemon.enable = true;
  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.gnome.core-apps.enable = false;
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
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.desktopManager.retroarch.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.groups.arr.members = ["bazarr" "jellyfin" "lidarr" "radarr" "sonarr" "transmission" "tygo"];
  users.users.tygo = {
    isNormalUser = true;
    description = "Tygo";
    extraGroups = [ "networkmanager" "lp" "input" "wheel" "video"];
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
      nh
      #retroarch-full
      winetricks
      cava
      ghidra
      #nixos-generators
      protontricks
      handbrake
      wvkbd
      p7zip
      soundconverter
      freac
      flac
      # Image and Video management
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

  # Ollama
  services.ollama = {
    enable = true;
    package = unstable.ollama;
    user = "ollama";
    group = "ollama";
  };

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
    yt-dlp
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
