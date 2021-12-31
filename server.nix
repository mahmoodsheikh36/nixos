{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
    ./wireguard-server.nix
  ];

  boot.loader.grub.device = "/dev/vda";

  environment.systemPackages = with pkgs; [
    redis
  ];
}
