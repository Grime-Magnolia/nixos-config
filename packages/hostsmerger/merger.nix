{ builtins,lib,pkgs, ... }:
hosts :
let
  fetcher = url:builtins.fetchurl url;
in lib.foreach hosts fetcher
