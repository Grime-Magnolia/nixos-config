{lib, pkgs,...}:
let
  cfg = config.pkgsPresets;
  presets = {
    "minimal"={};
    "full"={};
    "semi"={};
  };
in {
  options.pkgsPresets = {
    enable = lib.mkEnableOption "enable pkgsPresets module";
    preset = lib.mkOption {
      default = "minimal";
      type = lib.types.str;
      description = "allowed minimal full and semi";
    };
  };
  config = lib.mkIf cfg.enable {
    import presets.${cfg.preset};
  };
}
