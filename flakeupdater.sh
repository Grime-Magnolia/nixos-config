#!/bin/bash

nix flake metadata >old
nix flake update
nix flake metadata >new
colordiff -u new old
rm new old
