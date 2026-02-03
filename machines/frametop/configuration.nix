# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, builtins, stable, unstable, inputs, ... }:

let 
  forEach = xs: f: map f xs;
  pkgs-unstable = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in rec {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ./modules
  ];
  nix = {
    package = pkgs.nixVersions.latest;

    extraOptions = ''
      experimental-features = nix-command flakes impure-derivations ca-derivations
    '';
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 30d";
      persistent = false;
    };
    optimise = {
      automatic = true;
      persistent = false;
      dates = [
        "03:45"
      ];
    };
    settings = {
      trusted-users = [ "tygo" ];
      substituters = ["https://hyprland.cachix.org" "https://attic.xuyh0120.win/lantian"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
    };
  };
  # Local Arr stack on this instance when enabled
  arr = {
    enable = true;
    glance.enable = true;
    sonarr.key = "95fd7478053e47dd89102aead48908da";
    prowlarr.key = "a61160856c3242dc9fb17332d0c814fa";
    radarr.key = "28e25bce8551464bade6724c6da60b0f";
    readarr.key = "e43cea9107d14a02a34990b80b2efcd4";
    bazarr.key = "2c63ca8ebb624ae5f7df78e41a33023d";
    jellyfin.enable = false;
  };
  general.enable = true;

  # TLP for powerscaling
  services.tlp = {
    enable = true;
    settings = {
      # CPU scaling on ac and on battery
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

      CPU_DRIVER_OPMODE_ON_AC = "active";
      CPU_DRIVER_OPMODE_ON_BAT = "active";

      # GPU scaling on AC and on Battery
      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      RADEON_DPM_PERF_LEVEL_ON_AC="high";
      RADEON_DPM_PERF_LEVEL_ON_BAT="auto";

      RADEON_DPM_STATE_ON_AC="performance";
      RADEON_DPM_STATE_ON_BAT="balanced";
      
      AMDGPU_ABM_LEVEL_ON_AC=0;
      AMDGPU_ABM_LEVEL_ON_BAT=1;


      CPU_SCALING_MIN_FREQ_ON_AC=625000;
      CPU_SCALING_MAX_FREQ_ON_AC=4900000;
      CPU_SCALING_MIN_FREQ_ON_BAT=625000;
      CPU_SCALING_MAX_FREQ_ON_BAT=4900000;
      
      USB_AUTOSUSPEND = 1;
      USB_ALLOWLIST = "27c6:609c";
      SOUND_POWER_SAVE_ON_AC=0;
      SOUND_POWER_SAVE_ON_BAT=0;
      
      CPU_BOOST_ON_AC=1;
      CPU_BOOST_ON_BAT=1;
      # Optional helps save long term battery health
      #START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
      #STOP_CHARGE_THRESH_BAT0 = 80;  # 80 and above it stops charging
    };
  };
  # Swap
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64*1024; # 16 GB
  }];
  zramSwap.enable = true;
  #boot.loader.grub = {
  #  theme = "${stable.kdePackages.breeze-grub}/grub/themes/breeze";
  #};
  # Auto updates takes somehow 10 seconds to start
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    dates = "02:00";
    randomizedDelaySec = "45min";
    persistent = false;
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = stable.linuxPackages_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [
    #(pkgs.callPackage ../../packages/xrt/xrt.nix {latest=unstable;})
  ];
  hardware.firmware = [
  # (pkgs.callPackage ../../packages/xdna-driver/xdna-driver.nix {latest=unstable;}).firmware
  # (pkgs.callPackage ../../packages/xrt/xrt.nix {latest=unstable;})
  ];
  boot.kernelParams = [

    # Swap
    "zswap.enabled=1" # enables zswap
    "zswap.compressor=lz4" # compression algorithm
    "zswap.max_pool_percent=50" # maximum percentage of RAM that zswap is allowed to use
    "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
    
    # Suspending / Sleep settings
    "amd_iommu=fullflush" # Should make the suspending process more effecient

    "nvme_core.default_ps_max_latency_us=0"
    "nvme_core.io_timeout=30"
    "nvme_core.max_retries=10"
    "rtc_cmos.use_acpi_alarm=1"
  ];

  powerManagement.powertop.enable = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
  };
  # Networking stuff
  networking.extraHosts = '''';
  networking.hostName = "frametop"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };
  systemd.network.wait-online.enable = false;
  boot.initrd.systemd.network.wait-online.enable = false;
  # Printing
  services.printing.enable = true;
  services.printing.webInterface = true;
  services.printing.drivers = [stable.hplipWithPlugin];
  hardware.printers = lib.mkIf false {
    ensureDefaultPrinter = "HP_Color_LaserJet_MFP_M281fdw_CED640";
    ensurePrinters = [
      {
        deviceUri = "ipp://192.168.2.86/ipp";
        location = "home";
        name = "HP_Color_LaserJet_MFP_M281fdw_CED640";
        model = "everywhere";
        ppdOptions = {
          PageSize = "A4";
          Duplex = "DuplexNoTumble";
        };
      }
    ];
  };
  services.saned.enable = true;
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan];
    disabledDefaultBackends = [
      "escl"
    ];   # disable hpaio and others
    openFirewall = true;
  };
  services.udev.packages = [ pkgs.sane-airscan ];
  #services.udev.extraRules = ''
  #  KERNEL=="ttyACM[0-9]*", MODE="0666"
  #'';
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  hardware.graphics = { # hardware.graphics since NixOS 24.11
    enable = true;
    enable32Bit = true;
    package = stable.mesa;
    package32 = stable.pkgsi686Linux.mesa;
  };
  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;


  system.activationScripts.myst-symlink.text = ''
    ln -sf ${stable.bash}/bin/bash /bin/
    ln -sf ${stable.less}/bin/less /bin/
    ln -sf ${stable.sudo}/bin/sudo /bin/
    ln -sf ${stable.fish}/bin/fish /bin/
    ln -sf ${stable.python312}/bin/python3 /bin/
    ln -sf ${stable.stockfish}/bin/stockfish /bin/ 
    ln -sf ${stable.calculix-ccx}/bin/ccx /bin/ 
    ln -sf ${stable.gmsh}/bin/gmsh /bin/
  '';

  services = {
    fwupd.enable = true;
    resolved.enable = true;
    libinput.enable = true;
  };
  programs.fish.enable = true;
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = false;
  programs.steam.gamescopeSession.args = [
    "--expose-wayland"
  ];
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
  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.excludePackages = [stable.xterm];
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  # enable gfs and udisks2
  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.upower.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.noto
    nerd-fonts.jetbrains-mono
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    nerd-fonts.caskaydia-cove
  ];
  
  systemd.tmpfiles.rules = 
  let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];
  # Fingerprint shit
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };
  services.fprintd = {
    enable = true;
  }; 
  security.pam.services.login.fprintAuth = lib.mkForce true;
  security.pam.services.gdm-fingerprint = {
    fprintAuth = true;
    enableGnomeKeyring=true;
  };
  security.pam.services.gdm = {
    fprintAuth = true;
    enableGnomeKeyring = true;
  };

  security.pam.services.sudo.fprintAuth = true;  # optional
  services.logind.settings.Login.HandlePowerKey = "lock";

  fonts.fontDir.enable = true;
  services.power-profiles-daemon.enable = false;
  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.dconf.enable = true;
  services.gnome.core-apps.enable = false;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  #networking.useDHCP = true;
  # Enable sound with pipewire.
 
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.desktopManager.retroarch.enable = true;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  services.clamav = lib.mkIf false {
    daemon.enable = true;
    updater.enable = true;
    fangfrisch.enable = true;
    scanner.enable = true;
  };
  services.openssh = {
    enable = true;
  };
  programs.wireshark.enable = true;
  users.groups.arr.members = ["bazarr" "jellyfin" "lidarr" "radarr" "sonarr" "transmission" "tygo"];
  users.groups.wireshark.members = ["tygo"];
  users.users.tygo = {
    isNormalUser = true;
    description = "Tygo";
    extraGroups = [ "networkmanager" "dialout" "lp" "input" "wheel" "video" "wireshark" "scanner" "arr"];
    shell = stable.fish;
    packages = with stable; [
      #(pkgs.callPackage ../../packages/xrt/xrt.nix {latest=unstable;})
      logseq
      calc
      pipeline
      hyprpwcenter
      hyprlauncher
      perf
      perf-tools
      blender
      telegram-desktop
      super-slicer
      rawtherapee
      gnome-graphs
      prismlauncher
      wireshark
      clamav
      alpaca
      quickemu
      gamemode
      godot
      steam-devices-udev-rules
      superTuxKart
      imagemagick
      gnome-clocks
      xournalpp
      freeplane
      dualsensectl
      pcsx2
      jq
      orca-slicer
      freecad
      protonplus
      goverlay
      mangohud
      nh
      playerctl
      rpcs3
      mediainfo
      winetricks
      usbutils
      pciutils
      cava
      simple-scan
      gnomecast
      waywall
      unstable.metasploit
      ghidra
      handbrake
      wvkbd
      p7zip
      powertop
      soundconverter
      flac
      webcord
      evolution
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-libav
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-bad
      # Image and Video management
      libinput-gestures
      wtype
      xdotool
      helvum
      avizo
      rofi
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
      stockfish
      gimp
      kicad
      iotas
      planify
      ffmpeg_6-full
      ffsubsync
      mullvad-vpn
      signal-desktop
      cartridges
      eww
      hyprpolkitagent
      hyprshot
      grim
      slurp
      mpv
      kitty
    ];
  };
  services.mullvad-vpn.enable = true;
  # Ollama
  services.ollama = {
    enable = true;
    package = unstable.ollama;
    user = "ollama";
    group = "ollama";
  };

  # flatpak
  services.flatpak = {
    update.auto = {
      enable = true;
      onCalendar = "weekly"; # Default value
    };
    packages = [
      "page.codeberg.libre_menu_editor.LibreMenuEditor"
      "io.github.ungoogled_software.ungoogled_chromium"
      "io.freetubeapp.FreeTube"
      "com.usebottles.bottles"
      "com.mastermindzh.tidal-hifi"
      "com.github.eneshecan.WhatsAppForLinux"
      "com.github.IsmaelMartinez.teams_for_linux"
      "com.felipekinoshita.Wildcard"
      #{
      #  bundle = "https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak";
      #  appId = "com.hytale.launcher";
      #  sha256 = "494c5fca8bc2dae9999ac3a3e5b39367c59f182a6759ccfbb2f3844b035e915d";
      #}
    ];
  };
  # Hyprland apps
  programs.hyprland = {
    enable = true;
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  programs.hyprlock.enable = true;
  services.hypridle.enable = true;
  programs.localsend.enable = true;
  environment.systemPackages = with stable; [
    wget
    neovim
    papers
    vlc
    hyprpaper
    swww
    lm_sensors
    htop
    gimp
    krita
    inkscape
    sudo
    tldr
    brightnessctl
    baobab
    nautilus
    vulkan-tools
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
    pandoc
    lynx
    calibre
    #libgcc
    swaynotificationcenter
    gnome-text-editor
  ];
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = if true then with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    libxext
    libx11
    libxrender
    libxtst
    libxi
    libxft
    freetype
    libxcursor
    libxrandr
    libxxf86vm
    libGL
    openal
  ] else [];
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ stable.xdg-desktop-portal-hyprland ]; #inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland];
  xdg.portal.config.common.default = "gtk";
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };


  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
