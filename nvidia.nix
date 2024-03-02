{ config, pkgs, ... }:
{
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      # make sure to use the correct bus id values for your system!
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  boot.kernelParams = [ "module_blacklist=i915" ];
}
