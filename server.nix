{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
  ];

  goot.loader.grub.device = "/dev/vda";

  environment.systemPackages = with pkgs; [
    redis
  ];
}
