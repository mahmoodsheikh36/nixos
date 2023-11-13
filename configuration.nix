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
      #startx.enable = true;
      sx.enable = true;
      defaultSession = "none+awesome";
    };
    windowManager.awesome = {
      #package = with pkgs; awesomewm_git;
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
  };

  # tty configs
  console = {
    #earlySetup = true;
    font = "ter-i14b";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # remap caps to escape
  };
  security.sudo.configFile = ''
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
    '';
  };

  # enable some programs/services
  programs.zsh.enable = true;
  programs.adb.enable = true;
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.openssh.enable = true;
  services.syncthing = {
    enable = false;
    user = "mahmooz";
  };
  services.touchegg.enable = true;

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
    #(self: super:
    #{
      #awesomewm_git = super.awesome.overrideAttrs (oldAttrs: rec {
        #src = super.fetchFromGitHub {
          #owner = "awesomeWM";
          #repo = "awesome";
          #rev = "1932bd017f1fd433a74f621d9fe836e355ec054a";
          #sha256 = "07w4h7lzkq9drckn511qybskcx8cr9hmjmnxzdrxvyyda5lkcfmk";
        #};
      #});
    #})
  ];
  
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      fantasque-sans-mono
      google-fonts
      cascadia-code
      inconsolata-nerdfont
      iosevka
      fira-code
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];
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

  # list packages installed in system profile. To search, run:
  # $ nix search wget
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
    discord
    my_sxiv

    # media manipulation tools
    imagemagick
    ffmpeg
    gimp inkscape

    # general tools
    google-chrome qutebrowser firefox tor-browser-bundle-bin
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

    # x11 tools
    #xorg.xinit
    # sxhkd
    rofi
    libnotify
    xclip
    scrot
    picom
    parcellite

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
    flutter dart #android-studio
    texlive.combined.scheme-full
    rustc meson ninja
    git
    python3
    julia

    neovim
    curl wget nmap socat # networking tools

    # some helpful programs / other
    git tmux file vifm zip unzip fzf htop p7zip unrar-wrapper
    transmission gcc clang youtube-dl yt-dlp fzf acpi gnupg tree-sitter clang-tools

    # some build systems
    cmake gnumake

    # nodejs
    nodejs nodePackages.node2nix

    # nix specific tools
    nixos-generators
    nix-prefetch-git
 ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  system.stateVersion = "23.05"; # dont change
}

