{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
  ];

  environment.systemPackages = with pkgs; [
    redis
  ]
}
