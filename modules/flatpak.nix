{lib,config,pkgs,...}:
let
  cfg = config.flatpakApps;
in 
{
  options = {
    flatpakApps.enable = lib.mkEnableOption "Enables Flatpak apps module";
    flatpakApps.apps = lib.mkOption {
      default = [];
      type = lib.types.listOf.str;
      description = "The apps you would like to install";
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services."flatpak-setup" = {
      description = "Flatpak app installation";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = [ ''${pkgs.bash}/bin/bash -c "${pkgs.flatpak}/bin/flatpak install -y flathub ${lib.concatStringsSep " " cfg.apps}"'' ];
      };
    };
  };
}
