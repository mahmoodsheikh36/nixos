#!/usr/bin/env sh
cd ~/work/nixos/
sudo nixos-rebuild switch --upgrade --flake .#mahmooz --option eval-cache false --show-trace
