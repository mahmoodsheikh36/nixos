{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # main system config
  networking.hostName = "mahmooz";
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  networking.resolvconf.dnsExtensionMechanism = false;
  time.timeZone = "Asia/Jerusalem";

  # users
  users.users.mahmooz = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "audio" ];
    shell = pkgs.zsh;
  };
  security.sudo.configFile = ''
    mahmooz ALL=(ALL:ALL) NOPASSWD: ALL
  '';

  # ask for password in terminal instead of x11-ash-askpass
  programs.ssh.askPassword = "";

  # Enable sound and bluetooth
  sound.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = "
      load-module module-switch-on-connect
    ";
  };
  nixpkgs.config.pulseaudio = true;

  # enable some programs/services
  programs.zsh.enable = true;
  programs.adb.enable = true;
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad.disableWhileTyping = true;
    };
    displayManager.startx.enable = true;
    layout = "us";
    xkbOptions = "caps:swapescape";
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      fantasque-sans-mono
      google-fonts
    ];
  };

  # the NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # my overlays
  nixpkgs.overlays = [
    (self: super:
    {
      my_sxiv = super.sxiv.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "mahmoodsheikh36";
          repo = "sxiv";
          rev = "e10d3683bf9b26f514763408c86004a6593a2b66";
          sha256 = "161l59balzh3q8vlya1rs8g97s5s8mwc5lfspxcb2sv83d35410a";
        };
      });
    })
  ];

  # allow non-free packages to be installed
  nixpkgs.config.allowUnfree = true; 

  # packages
  environment.systemPackages = with pkgs; [
    # (import ./scripts.nix).hello
    # (import ./scripts.nix).what

    # text editors
    emacs
    neovim vimPlugins.Vundle-vim

    # networking tools
    curl
    wpa_supplicant
    networkmanager
    # required for wireless AP setup
    # hostapd dnsmasq bridge-utils

    # media tools
    mpv
    spotify spotify-tui
    feh # i use it to set wallpaper
    my_sxiv

    # media manipulation tools
    imagemagick
    ffmpeg
    gimp

    # general tools
    firefox
    awesome
    discord
    scrcpy
    tdesktop
    tor-browser-bundle-bin
    pavucontrol
    git

    # commandline tools
    alacritty kitty # terminal emulator
    zsh
    bat
    lsd
    tmux
    cmake
    pulsemixer # tui for pulseaudio control
    playerctl # media control
    nix-index # helps finding the package that contains a specific file
    vifm # file manager
    gnumake
    gcc
    file
    youtube-dl
    iw
    transmission
    acpi
    fzf
    unzip
    pciutils
    linux-router

    # x11 tools
    xorg.xinit
    sxhkd
    rofi
    libnotify
    xclip
    scrot
    picom

    # python
    (python38.withPackages(ps: with ps; [ 
       numpy requests beautifulsoup4 flask mysql-connector
    ]))
    # other programming languages
    yarn nodejs
    lua
    dart flutter android-studio

    # libs
    imlib2 x11 libexif giflib # required to compile sxiv
    libtool # requried to build vterm on emacs

    # nix specific tools
    nixos-generators
    nix-prefetch-git
    nur.repos.mic92.hello-nur
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
