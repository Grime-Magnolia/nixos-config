{ inputs, lib, config, pkgs, ... }:

let 
  # Convert a single hex character ("0"-"f") to int
  hexDigit = c: let 
    table = {
    "0" = 0; "1" = 1; "2" = 2; "3" = 3;
    "4" = 4; "5" = 5; "6" = 6; "7" = 7;
    "8" = 8; "9" = 9; "a" = 10; "b" = 11;
    "c" = 12; "d" = 13; "e" = 14; "f" = 15;
    "A" = 10; "B" = 11; "C" = 12;
    "D" = 13; "E" = 14; "F" = 15;
    };
  in table.${c};

  # Convert two-digit hex ("7b") to int
  hexToInt = hex: let
    hi = hexDigit (builtins.substring 0 1 hex);
    lo = hexDigit (builtins.substring 1 1 hex);
  in hi * 16 + lo;
  # Converts a two-digit hex string to an int
  #hexToInt = hex: lib.strings.toInt hex;

  # Main function: "#rrggbb" → { r = int; g = int; b = int; }
  hexToRgb = hex: let
    clean = lib.strings.removePrefix "#" hex;
    r = hexToInt (builtins.substring 0 2 clean);
    g = hexToInt (builtins.substring 2 2 clean);
    b = hexToInt (builtins.substring 4 2 clean);
  in { inherit r g b; };
  hexToRgba = hex: alpha: let 
    c = hexToRgb hex;
    in "rgba(${builtins.toString c.r}, ${builtins.toString c.g}, ${builtins.toString c.b}, ${builtins.toString alpha})";
  color = config.lib.stylix.colors.withHashtag; 
in {
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #xdg.configFile."waybar/config.jsonc".source = ./waybar/config.jsonc;
  wayland.windowManager.hyprland = {
    enable = true ;
    settings = {
        source = "initializer.conf";
      };
    plugins = [
      pkgs.hyprlandPlugins.hyprgrass
    ];
  };
  programs.waybar = {
    enable = true;
    settings.main = {
      layer = "top";
      position = "bottom";
      height = 30;
      spacing = 9;  
      width = 1200;
      modules-left = ["idle_inhibitor" "tray" "custom/dualsense"];
      modules-center = ["clock"];
      modules-right = [
        "pulseaudio"
        "cpu"
        "memory"
        "temperature"
        "network"
        "battery"
      ];
      idle_inhibitor = {
        format = "{icon}";
        format-icons = {
          activated = "";
          deactivated = "";
        };
      };
      pulseaudio = {  
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-muted = " {format_source}";
        format-source = "{volume}%";
        format-source-muted = "";
        format-icons = {  
          headphone = "";
          hands-free = "";
          headset = "";
          phone = "";
          portable = "?";
          car = "";
          default = ["" "" ""];
        };
        on-click = "pavucontrol";
      };
      tray = {  
        spacing = 10;
      };
      "custom/dualsense" = rec {
        hide-empty-text = false;
        format = "󰊴 {text}";
        exec = "${pkgs.dualsensectl}/bin/dualsensectl battery|grep -oE '[0-9]+'";
        on-update = exec;
        interval = 10;
      };
      clock = { 
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        format-alt = "{:%Y-%m-%d}";
      };
      cpu = { 
        format = "{usage}% ";
        tooltip = false;
      };
      memory = {
        format = "{}% ";
      };
      temperature = { 
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = ["" "" "" ""];
      };
      battery = { 
        states = {
          warning = 30;
          critical = 15;
        };
        full-at = 100;
        format = "{capacity}% {icon}";
        format-full = "{capacity}% {icon}";
        format-charging = "{capacity}% ";
        format-plugged = "{capacity}% ";
        format-alt = "{time} {icon}";
        format-icons = ["" "" "" "" ];
      };
      power-profiles-daemon = { 
        format = "{icon}";
        tooltip-format = "Power profile: {profile}\nDriver: {driver}";
        tooltip = true;
        format-icons = {
          default = "󰾅";
          performance = "󰓅";
          balanced = "󰾅";
          power-saver = "󰾆";
        };
      };
      network = {
        format-wifi = "{essid} ({signalStrength}%) ";
        format-ethernet = "{ipaddr}/{cidr} ";
        tooltip-format = "{ifname} via {gwaddr} ";
        format-linked = "{ifname} (No IP) <U+F796>";
        format-disconnected = "Disconnected ⚠";
        format-alt = "{ifname}: {ipaddr}/{cidr}";
      };
    };
    style = let 
        # Convert a single hex character ("0"-"f") to int
      hexDigit = c:
      let
        table = {
          "0" = 0; "1" = 1; "2" = 2; "3" = 3;
          "4" = 4; "5" = 5; "6" = 6; "7" = 7;
          "8" = 8; "9" = 9; "a" = 10; "b" = 11;
          "c" = 12; "d" = 13; "e" = 14; "f" = 15;
          "A" = 10; "B" = 11; "C" = 12;
          "D" = 13; "E" = 14; "F" = 15;
        };
      in table.${c};

      # Convert two-digit hex ("7b") to int
      hexToInt = hex:
      let
        hi = hexDigit (builtins.substring 0 1 hex);
        lo = hexDigit (builtins.substring 1 1 hex);
      in hi * 16 + lo;
      # Converts a two-digit hex string to an int
      #hexToInt = hex: lib.strings.toInt hex;

      # Main function: "#rrggbb" → { r = int; g = int; b = int; }
      hexToRgb = hex:
      let
        clean = lib.strings.removePrefix "#" hex;
          r = hexToInt (builtins.substring 0 2 clean);
          g = hexToInt (builtins.substring 2 2 clean);
          b = hexToInt (builtins.substring 4 2 clean);
        in { inherit r g b; };
      hexToRgba = hex: alpha: let 
        c = hexToRgb hex;
      in "rgba(${builtins.toString c.r}, ${builtins.toString c.g}, ${builtins.toString c.b}, ${builtins.toString alpha})";
      color = config.lib.stylix.colors.withHashtag;
    in ''
* {
    font-family: 'Noto Sans Mono', 'Font Awesome 6 Free', 'Font Awesome 6 Brands', monospace;
    font-size: 13px;
}

window#waybar {
    background-color: ${hexToRgba color.base00 "0.5"};
    border-bottom: 3px solid ${hexToRgba color.base01 "0.5"};
    color: ${hexToRgba color.base05 "1.0"};
    transition-property: background-color;
    transition-duration: .5s;
    border: 2px solid ${hexToRgba color.base01 "0.5"};
    border-radius: 10px; /* Rounded corners */ 
    padding-left: 200px;
    padding-right: 200px;
    padding-left: 10px;
    padding-right: 10px;
}

window#waybar.hidden {
    opacity: 0.2;
}
window#waybar.termite {
    background-color: #3F3F3F;
}

window#waybar.chromium {
    background-color: #000000;
    border: none;
}

button {
    /* Use box-shadow instead of border so the text isn't offset */
    box-shadow: inset 0 -3px transparent;
    /* Avoid rounded borders under each button name */
    border: none;
    border-radius: 0;
}

/* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
button:hover {
    background: inherit;
    box-shadow: inset 0 -3px #ffffff;
}

/* you can set a style on hover for any module like this */
#pulseaudio:hover {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #64727D;
    box-shadow: inset 0 -3px #ffffff;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#mode {
    background-color: #64727D;
    box-shadow: inset 0 -3px #ffffff;
}

/* If workspaces is the leftmost module, omit left margin */
.modules-left > widget:first-child > #workspaces {
    margin-left: 0;
}

/* If workspaces is the rightmost module, omit right margin */
.modules-right > widget:last-child > #workspaces {
    margin-right: 0;
}

#clock {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    border-radius: 15px;
}

#battery {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    border-radius: 15px;
}

#battery.charging, #battery.plugged {
    color: ${hexToRgba color.base05 "1.0"};
    background-color: ${hexToRgba color.base01 "1.0"};
}

@keyframes blink {
    to {
        background-color: ${hexToRgba color.base01 "1.0"};
        color: ${hexToRgba color.base05 "1.0"};
    }
}

/* Using steps() instead of linear as a timing function to limit cpu usage */
#battery.critical:not(.charging) {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base0E "1.0"};
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: steps(12);
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

#power-profiles-daemon {
    padding-right: 15px;
    padding-left: 15px;
    border-radius: 15px;
}

#power-profiles-daemon.performance {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
}

#power-profiles-daemon.balanced {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
}

#power-profiles-daemon.power-saver {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
}

label:focus {
    background-color: #000000;
}

#cpu {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    border-radius: 15px;
    padding-left: 15px;
    padding-right: 15px;
}

#memory {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    border-radius: 15px;
    padding-right: 15px;
    padding-left: 15px;
}

#backlight {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
}

#network {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    border-radius: 15px;
    padding-right: 15px;
    padding-left: 15px;
}

#network.disconnected {
    background-color: ${hexToRgba color.base0F "1.0"};
}

#pulseaudio {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    border-radius: 15px;
}

#pulseaudio.muted {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
}

#wireplumber {
    background-color: #fff0f5;
    color: #000000;
}

#wireplumber.muted {
    background-color: #f53c3c;
}

#custom-media {
    background-color: #66cc99;
    color: #2a5c45;
    min-width: 100px;
}

#custom-media.custom-spotify {
    background-color: #66cc99;
}

#custom-media.custom-vlc {
    background-color: #ffa000;
}

#temperature {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    border-radius: 15px;
}

#temperature.critical {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base0F "1.0"};
}

#tray {
    background-color: ${hexToRgba color.base01 "1.0"};
    border-radius: 15px;
    padding-left: 15px;
    padding-right: 15px;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: ${hexToRgba color.base0F "1.0"};
}

#idle_inhibitor {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
    padding-right: 15px;
    padding-left: 15px;
    border-radius: 15px;
}

#idle_inhibitor.activated {
    background-color: ${hexToRgba color.base01 "1.0"};
    color: ${hexToRgba color.base05 "1.0"};
}


#privacy {
    padding: 0;
}

#privacy-item {
    padding: 0 5px;
    color: white;
}

#privacy-item.screenshare {
    background-color: #cf5700;
}

#privacy-item.audio-in {
    background-color: #1ca000;
}

#privacy-item.audio-out {
    background-color: #0069d4;
}
    '';
  };
  programs.hyprlock = { 
    enable = false;
    settings = {
      general = {};
      background = [
        {
          path = "${../../wallpapers/Sunset_cam.jpg}";
        }
      ];
      input-field = [
        { 
          size = "350, 50";
          outline_thickness = 8;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = false;
          dots_rounding = -1;
          outer_color = "rgba(0, 207, 230, 0.0)";
          inner_color = "rgba(155,255,255,0.0)";

        }
      ];
    };
  };
  #stylix = {
  #  targets = {
  #    cava.rainbow.enable = true;
  #  };
  #};
  home.stateVersion = "24.11";
}
