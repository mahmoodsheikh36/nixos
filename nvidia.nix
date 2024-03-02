{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      # make sure to use the correct bus id values for your system!
      intelBusId = "PCI:0:0:2";
      nvidiaBusId = "PCI:0:1:0";
    };
  };
}