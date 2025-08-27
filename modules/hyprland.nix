{ config, lib, unstable, pkgs, ..}:
{
  imports = [];
  options = {
    hyprland.enable = lib.mkEnableOption "Enables Hyprland and this module";
    hyprland.hyprpaper.enable = lib.mkEnableOption "Enables hyprpaper";
    hyprland.hypridle.enable = lib.mkEnableOption "Enable hypridle";
    hyprland.rofi.enable = lib.mkEnableOption "Enable Rofi";
    hyprland.waybar.enable = lib.mkEnableOption "Enable Waybar";
  };
  config = lib.mkIf config.hyprland.enable {
    
  };
}
