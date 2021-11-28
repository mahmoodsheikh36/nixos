{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # enable experimental features to avoid problems when running "nix search"
  nix.extraOptions = "extra-experimental-features = nix-command flakes";

  # bootloader/kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  #boot.initrd.kernelModules = [];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl88xxau-aircrack
  ];
  boot.kernelModules = [ "kvm-intel" "iwlwifi" "rtl8812au" ];
  hardware.enableRedistributableFirmware = true;

  # networking
  networking.hostName = "mahmooz";
  networking.networkmanager.enable = true;
  networking.enableIPv6 = false;
  networking.resolvconf.dnsExtensionMechanism = false;

  # general system config
  time.timeZone = "Asia/Jerusalem";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave"; # no idea what that is lol

  # users
  users.users.mahmooz = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "audio" ];
    shell = pkgs.zsh;
    password = "mahmooz";
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
    layout = "us";
    xkbOptions = "caps:swapescape";
    displayManager.startx.enable = true;
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
  };

  # nvidia config
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.prime = {
    offload.enable = true;
    # bus id of the intel gpu, can be obtained using lspci/lshw
    intelBusId = "PCI:0:2:0";
    # bus id of the nvidia gpu, can be obtained using lspci/lshw
    nvidiaBusId = "PCI:1:0:0";
  };

  # tty configs
  console = {
    #earlySetup = true;
    font = "ter-i14b";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # remap caps to escape
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      fantasque-sans-mono
      google-fonts
    ];
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
    # text editors
    emacs
    neovim vimPlugins.Vundle-vim

    # networking tools
    curl wget macchanger arp-scan nmap iftop

    # media tools
    mpv
    spotify
    feh # i use it to set wallpaper
    my_sxiv
    zathura

    # media manipulation tools
    imagemagick
    ffmpeg
    gimp

    # general tools
    firefox brave qutebrowser
    awesome
    discord
    scrcpy
    tdesktop
    pavucontrol
    git
    libreoffice

    # commandline tools
    kitty # terminal emulator
    zsh tmux
    bat lsd file
    cmake
    pulsemixer # tui for pulseaudio control
    playerctl # media control
    nix-index # helps finding the package that contains a specific file
    vifm # file manager
    gnumake
    gnupg
    gcc
    youtube-dl yt-dlp
    iw
    transmission
    acpi
    fzf
    unzip
    pciutils
    sqlite
    irssi
    gptfdisk parted
    ag # the silver searcher i use it for emacs
    ghostscript # i use this to view pdfs in emacs
    xdotool

    # x11 tools
    xorg.xinit
    sxhkd
    rofi
    libnotify
    xclip
    scrot
    picom

    # other
    redis

    # python
    (python38.withPackages(ps: with ps; [ 
       numpy requests beautifulsoup4 flask mysql-connector
       pip redis
    ]))
    # other programming languages
    yarn nodejs
    lua
    openjdk8
    flutter dart
    texlive.combined.scheme-basic

    # libs
    imlib2 x11 libexif giflib # required to compile sxiv
    libtool # requried to build vterm on emacs

    # nix specific tools
    nixos-generators
    nix-prefetch-git
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
