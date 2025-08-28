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
      git
      bat
      neovim
      starship
    ]);
    programs.fish.enable = true;
    users.defaultUserShell = pkgs.fish;
    # wont work with flakes
    # system.copySystemConfiguration = true;
    nix = {
      package = pkgs.nixVersions.stable;

      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
  };
}
