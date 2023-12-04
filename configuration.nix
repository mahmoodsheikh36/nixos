{ config, pkgs, ... }:

{
  imports =
    [ # include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
    
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # enable sound and bluetooth
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
    # extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = "
      load-module module-switch-on-connect
    ";
  };
  nixpkgs.config.pulseaudio = true;

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
      my_awesome = super.awesome.overrideAttrs (oldAttrs: rec {
      postPatch = ''
        patchShebangs tests/examples/_postprocess.lua
      '';
      patches = [];
      src = super.fetchFromGitHub {
          owner = "awesomeWM";
          repo = "awesome";
          rev = "7ed4dd620bc73ba87a1f88e6f126aed348f94458";
          sha256 = "0qz21z3idimw1hlmr23ffl0iwr7128wywjcygss6phyhq5zn5bx3";
        };
      });
    })
    

  ];

  # x11 and awesomewm
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        tappingDragLock = false;
	      accelSpeed = "0.7";
      };
    };
    layout = "us";
    xkbOptions = "caps:swapescape";
    displayManager = {
      # sddm = {
      #   enable = true;
      # };
      autoLogin.enable = true;
      autoLogin.user = "mahmooz";
      startx.enable = true;
      sx.enable = true;
      defaultSession = "none+awesome";
    };
    windowManager.awesome = {
      package = with pkgs; my_awesome;
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };


  # tty configs
  console = {
    #earlySetup = true;
    font = "ter-i14b";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # remap caps to escape
  };
  security.sudo.extraConfig = ''
    mahmooz ALL=(ALL:ALL) NOPASSWD: ALL
  '';
  
  time.timeZone = "Asia/Jerusalem";
  
  # ask for password in terminal instead of x11-ash-askpass
  programs.ssh.askPassword = "";
  
  # networking
  networking = {
    hostName = "mahmooz";
    enableIPv6 = false;
    resolvconf.dnsExtensionMechanism = false;
    networkmanager.enable = true;
    extraHosts = ''
        157.230.112.219 server1
        45.32.253.181 server2
        127.0.0.1 youtube.com
        127.0.0.1 www.youtube.com
        127.0.0.1 reddit.com
        127.0.0.1 www.reddit.com
        # 127.0.0.1 discord.com
        # 127.0.0.1 www.discord.com
    '';
  };

  # enable some programs/services
  programs.zsh.enable = true;
  programs.adb.enable = true;
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.openssh.enable = true;
  services.syncthing = {
    enable = true;
    user = "mahmooz";
  };
  services.touchegg.enable = true;
  
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      fantasque-sans-mono
      google-fonts
      cascadia-code
      inconsolata-nerdfont
      iosevka
      fira-code
      nerdfonts
      ubuntu_font_family
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      # Persian Font
      vazir-fonts
      font-awesome
      iosevka
      # corefonts # MS fonts?
    ];
    # not sure if i need these 2
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fontconfig = {
      enable = true;
      antialias = true;
      cache32Bit = true;
      # defaultFonts = {
      #   emoji = ["Noto Color Emoji"];
      #   monospace = [ "Noto Mono" ];
      #   sansSerif = [ "Noto Sans" ];
      #   serif = [ "Noto Serif" ];
      hinting.autohint = true;
      hinting.enable = true;
      # hinting.style = "slight";
    };
  };

  # users
  users.users.mahmooz = {
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" ];
    shell = pkgs.zsh;
    password = "mahmooz";
    packages = with pkgs; [
    ];
  };

  # dictionaries
  services.dictd.enable = true;
  services.dictd.DBs = with pkgs.dictdDBs; [ wiktionary wordnet ];

  # packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # text editors
    emacs29
    vscode
    neovim
    vim

    # media tools
    mpv
    spotify
    feh # i use it to set wallpaper
    zathura
    # discord
    my_sxiv
    telegram-desktop
    zoom-us
    youtube-music
    okular
    xournalpp gnome.adwaita-icon-theme # the icon theme is needed for xournalpp to work otherwise it crashes
    ocrmypdf
    pandoc

    # media manipulation tools
    imagemagick
    ffmpeg
    gimp inkscape

    # general tools
    google-chrome qutebrowser tor-browser-bundle-bin
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
    # ghostscript # i use this to view pdfs in emacs
    libtool # to compile vterm
    xdotool
    docker
    jq
    ripgrep
    pdftk pdfgrep

    # x11 tools
    #xorg.xinit
    # sxhkd
    rofi
    libnotify
    xclip
    scrot
    picom
    parcellite
    hsetroot
    unclutter

    # other
    redis
    bluetooth_battery # command to get battery percentage of current headset
    #zoom-us
    hugo
    syncthing
    adb-sync
    woeusb-ng
    ntfs3g
    gnupg1orig
    pigz pinentry
    SDL2

    # virtualization tools
    qemu virt-manager

    # science
    gnuplot
    sage sagetex

    # some programming languages/environments
    lua
    openjdk8
    # flutter dart #android-studio
    texlive.combined.scheme-full
    rustc meson ninja
    git
    python3
    julia
    jupyter python311Packages.jupyter python311Packages.jupyter-core
    typescript

    neovim
    curl wget nmap socat arp-scan traceroute # networking tools

    # some helpful programs / other
    git tmux file vifm zip unzip fzf htop p7zip unrar-wrapper
    transmission gcc clang youtube-dl yt-dlp fzf acpi gnupg tree-sitter clang-tools
    cryptsetup

    # some build systems
    cmake gnumake

    # nodejs
    nodejs nodePackages.node2nix

    # nix specific tools
    nixos-generators
    nix-prefetch-git
 ];

  system.stateVersion = "23.05"; # dont change
}