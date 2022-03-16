{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
  ];

  # bootloader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl88xxau-aircrack
  ];
  boot.kernelModules = [ "kvm-intel" "iwlwifi" "rtl8812au" ];
  hardware.enableRedistributableFirmware = true;

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

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        tappingDragLock = false;
      };
    };
    layout = "us";
    xkbOptions = "caps:swapescape";
    displayManager.startx.enable = true;
    windowManager.awesome = {
      package = with pkgs; awesomewm_git;
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
  };

  # nvidia config
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.modesetting.enable = true;
  #hardware.nvidia.prime = {
  #  offload.enable = true;
  #  # bus id of the intel gpu, can be obtained using lspci/lshw
  #  intelBusId = "PCI:0:2:0";
  #  # bus id of the nvidia gpu, can be obtained using lspci/lshw
  #  nvidiaBusId = "PCI:1:0:0";
  #};

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
    (self: super:
    {
      awesomewm_git = super.awesome.overrideAttrs (oldAttrs: rec {
        src = super.fetchFromGitHub {
          owner = "awesomeWM";
          repo = "awesome";
          rev = "1932bd017f1fd433a74f621d9fe836e355ec054a";
          sha256 = "07w4h7lzkq9drckn511qybskcx8cr9hmjmnxzdrxvyyda5lkcfmk";
        };
      });
    })
  ];

  # packages
  environment.systemPackages = with pkgs; [
    # text editors
    emacs

    # media tools
    mpv
    spotify
    feh # i use it to set wallpaper
    my_sxiv
    zathura
    discord

    # media manipulation tools
    imagemagick
    ffmpeg
    gimp

    # general tools
    firefox qutebrowser google-chrome
    scrcpy
    pavucontrol
    libreoffice

    # commandline tools
    kitty # terminal emulator
    pulsemixer # tui for pulseaudio control
    playerctl # media control
    nix-index # helps finding the package that contains a specific file
    sqlite
    gptfdisk parted
    silver-searcher # the silver searcher i use it for emacs
    ghostscript # i use this to view pdfs in emacs
    xdotool
    docker

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
    bluetooth_battery # command to get battery percentage of current headset
    zoom-us

    # virtualization tools
    qemu virt-manager

    # science
    gnuplot
    sage

    (python38.withPackages(ps: with ps; [ 
      numpy requests beautifulsoup4 flask mysql-connector
      pip redis sage
    ]))

    # some programming languages/environments
    lua
    openjdk8
    flutter dart #android-studio
    texlive.combined.scheme-full
    rustc meson ninja
  ];

  system.stateVersion = "21.11"; # Did you read the comment?
}
