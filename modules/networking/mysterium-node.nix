{lib,pkgs,config,...}:
with lib;
let
  cfg = config.services.mysterium-node;

  mystConfig = if cfg.enable 
    then pkgs.runCommand "myst-supervisor-conf" {
      nativeBuildInputs = [ pkgs.remarshal ];
    } ''
      mkdir -p $out
      echo '${builtins.toJSON cfg.settings}' > $out/config.json
      json2toml "$out/config.json" "$out/myst_supervisor.conf"
    '' else null;
in {
  options.services.mysterium-node = {
    enable = mkEnableOption "Mysterium VPN node - daemon";
    binary = mkOption {
      type = types.path;
      default = "${pkgs.myst}/bin/myst";
      description = "Package providing the myst binary.";
    };
    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ "--agreed-terms-and-conditions" ];
      description = "Extra arguments to pass to the myst service command.";
    };
    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "config passed to /etc/myst_supervisor.conf";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.mysterium-node = {
      description = "Mysterium VPN Node";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.binary}/bin/myst service --agreed-terms-and-conditions";
        Restart = "always";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        AmbientCapabilities = "CAP_NET_ADMIN";
      };
    };
  };
}
