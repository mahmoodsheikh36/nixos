{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
  ];

  boot.loader.grub.device = "/dev/vda";

  environment.systemPackages = with pkgs; [
    redis
  ];
}
