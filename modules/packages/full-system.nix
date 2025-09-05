{lib,pkgs,unstable,...}:
let
  cfg = config.fullSystem
in 
{
  options = with lib; {
    fullSystem.enable = mkEnableOption "enable the all packages for my system"
  };
  config = lib.mkIf cfg.enable {

  };
}
