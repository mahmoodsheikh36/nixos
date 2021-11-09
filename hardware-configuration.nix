{ config, lib, pkgs, modulesPath, ... }:

{
  # filesystem
  fileSystems = {
    "/" = {
      label = "nixos";
      fsType = "ext4";
    };
    "/boot" = {
      label = "boot";
      fsType = "vfat";
    };
  };
  swapDevices = [{
    label = "swap";
  }];
}
