{ lib, pkgs, writeScript, ... }:
writeScript "autotuner" ''
  #!${pkgs.runtimeShell}
  powertop --auto-tune-dump 2>/dev/null \
    | awk '/### auto-tune-dump commands BEGIN/{flag=1; next}/### auto-tune-dump commands END/{flag=0; exit} flag && $0 ~ /^# echo/ {sub(/^# /,""); print}'
''
