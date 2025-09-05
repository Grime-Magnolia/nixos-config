{pkgs,unstable,lib,input,config,...}:
let
  cfg = config.general;
in {
  imports = [];
  options.general = {
    enable = lib.mkEnableOption "enables all apps and settings normaly used";
    
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.mkAfter (with pkgs; [
      kitty
      colordiff
      git
      bat
      neovim
      starship
      nh
    ]);
    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;
    services.fwupd.enable = true;
    # wont work with flakes
    # system.copySystemConfiguration = true;
  };
}
