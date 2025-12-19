{ pkgs, ... }:
pkgs.runCommand "tuner" {
  __impure = true;  # This is the key
  __noChroot = true; # removes sandboxing YES THIS IS DANGEROUS
  buildInputs = [ pkgs.powertop pkgs.gawk ];
} ''
  mkdir -p $out
  powertop --auto-tune-dump 2>/dev/null \
    | awk '
      /### auto-tune-dump commands BEGIN/ {flag=1; next}
      /### auto-tune-dump commands END/   {flag=0; exit}
      flag && $0 ~ /^# echo/ {
        sub(/^# /, "")
        print
      }
    ' > $out/tuner.sh
  chmod +x $out/tuner.sh
''

