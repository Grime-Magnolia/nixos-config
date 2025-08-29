{lib,pkgs,config,lib,...}:
with lib;
let
  cfg = config.services.mysterium-node;
in {
  options.services.mysterium-node = {
    enable = mkEnableOption "Mysterium VPN node - daemon";
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage pkgs.myst { };
      description = "Package providing the myst binary.";
    };
    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ "--agreed-terms-and-conditions" ];
      description = "Extra arguments to pass to the myst service command.";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.mysterium-node = {
      description = "Mysterium VPN Node";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${cfg.package}/bin/myst service --agreed-terms-and-conditions";
        Restart = "always";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        AmbientCapabilities = "CAP_NET_ADMIN";
      };
    };
  };
}
