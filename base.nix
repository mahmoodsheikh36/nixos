{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "mahmooz";
    enableIPv6 = false;
    resolvconf.dnsExtensionMechanism = false;
    networkmanager.enable = true;
    extraHosts = ''
        157.230.112.219 server
        45.32.253.181 server2
    '';
  };

  # general system config
  time.timeZone = "Asia/Jerusalem";

  # users
  users.users.mahmooz = {
    isNormalUser = true;
    extraGroups = [ "audio" ];
    shell = pkgs.zsh;
    password = "mahmooz";
  };
  security.sudo.configFile = ''
    mahmooz ALL=(ALL:ALL) NOPASSWD: ALL
  '';

  # enable some programs/services
  programs.zsh.enable = true;
  programs.adb.enable = true;
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.openssh.enable = true;

  # tty configs
  console = {
    #earlySetup = true;
    font = "ter-i14b";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # remap caps to escape
  };

  # allow non-free packages to be installed
  nixpkgs.config.allowUnfree = true; 

  environment.systemPackages = with pkgs; [
    neovim
    curl wget nmap # networking tools

    # some helpful programs / other
    git tmux file vifm zip unzip fzf htop
    transmission gcc youtube-dl fzf acpi gnupg

    # some build systems
    cmake gnumake

    # python
    (python38.withPackages(ps: with ps; [ 
       numpy requests beautifulsoup4 flask mysql-connector
       pip redis
    ]))

    # nodejs
    nodejs nodePackages.node2nix

    # nix specific tools
    nixos-generators
    nix-prefetch-git
  ];
}
