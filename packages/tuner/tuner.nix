{ pkgs, ... }:
pkgs.runCommand "tuner" {
  __impure = true;
  __noChroot = true;
  buildInputs = [ pkgs.powertop pkgs.gawk pkgs.coreutils ];
} ''
  mkdir -p $out
  echo "=== BUILD DEBUG ===" >&2
  echo "User: $(whoami)" >&2
  echo "UID: $(id -u)" >&2
  echo "EUID: $(id -u -r)" >&2
  echo "Groups: $(id)" >&2
  echo "=== Running powertop ===" >&2
  powertop --auto-tune-dump 2>/dev/null || {
    echo "powertop FAILED with exit code $?" >&2
    powertop --version >&2
    ls -la /sys/power/ >&2 || true
    exit 1
  }
  # rest unchanged...
''

