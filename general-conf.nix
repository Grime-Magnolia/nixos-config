{pkgs,unstable,lib,input,config,...}:
let
  cfg = config.general;
in {
  imports = [];
  options.general = {
    enable = lib.mkEnableOption "enables all apps and settings normaly used";
    
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = config.environment.systemPackages ++ (with pkgs; [
      kitty
    ]);
    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;
    system.copySystemConfiguration = true;
  };
}
