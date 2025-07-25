{ inputs, config, pkgs, ... }:

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  
  wayland.windowManager.hyprland.plugins = [
    pkgs.hyprlandPlugins.hyprtrails
    pkgs.hyprlandPlugins.hyprgrass
  ];
  home.stateVersion = "24.11";
}

