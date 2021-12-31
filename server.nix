{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
  ];

  boot.loader.grub.device = "/dev/vda";

  services = {
    openvpn.servers = {
      myvpn = {
        config = ''
          dev tun
          client
          proto tcp
          ca /home/markus/vpn/my-vpn-name/my-vpn-name.ca
          cert /home/markus/vpn/my-vpn-name/my-vpn-name.cert
          key /home/markus/vpn/my-vpn-name/my-vpn-name.key
          auth-user-pass /home/markus/vpn/my-vpn-name/my-vpn-name.cred
          ... other vpn config
        '';
        autoStart = false;
        updateResolvConf = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    redis
  ];
}
