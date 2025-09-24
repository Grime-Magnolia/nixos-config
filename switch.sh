#!/bin/fish

sudo nixos-rebuild switch --flake .
git log --oneline --decorate --all | head -n 1 | string split " " | head -n 1 >lastswitch.txt
