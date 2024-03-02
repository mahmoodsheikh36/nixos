{ config, pkgs, ... }:
{
  imports = [
    ./configuration.nix
    ./nvidia.nix
  ];
}