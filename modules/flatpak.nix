{lib,config,pkgs,...}:
let
  cfg = config.flatpak-apps

in 
{
  options = with flatpakApps; {
    enable = mkEnableOption "Enables Flatpak apps module";
    apps = mkOption {
      default = [];
      type = lib.types.listOf.str;
      description = "The apps you would like to install";
    };
  };
  config = lib.mkIf cfg.flatpak-apps {
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
