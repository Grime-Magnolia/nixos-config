{ pkgs, ... }:
pkgs.runCommand "tuner" {
  __impure = true;
  __noChroot = true;
  buildInputs = [ pkgs.powertop pkgs.gawk pkgs.sudo ];
} ''
  mkdir -p $out
  sudo powertop --auto-tune-dump 2>/dev/null \
    | awk '
      /### auto-tune-dump commands BEGIN/ {flag=1; next}
      /### auto-tune-dump commands END/   {flag=0; exit}
      flag && $0 ~ /^# echo/ {
        sub(/^# /, "")
        print
      }
    ' > $out/tuner.sh
  chmod +x $out/tuner.sh
  cat $out/tuner.sh
''

