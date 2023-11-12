# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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
    # extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
    extraConfig = "
      load-module module-switch-on-connect
    ";
  };
  nixpkgs.config.pulseaudio = true;

  # x11
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        tappingDragLock = false;
	accelSpeed = "2.0";
      };
    };
    layout = "us";
    xkbOptions = "caps:swapescape";
    displayManager.startx.enable = true;
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
    packages = with pkgs; [ terminus_font fira-code ];
    useXkbConfig = true; # remap caps to escape
  };
  security.sudo.configFile = ''
    mahmooz ALL=(ALL:ALL) NOPASSWD: ALL
  '';
  # general system config
  time.timeZone = "Asia/Jerusalem";
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

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users
  users.users.mahmooz = {
    isNormalUser = true;
    extraGroups = [ "audio" ];
    shell = pkgs.zsh;
    password = "mahmooz";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
nixpkgs.config.allowUnfree = true;
 environment.systemPackages = with pkgs; [
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

    # x11 tools
    xorg.xinit
    sxhkd
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

    neovim
    curl wget nmap # networking tools

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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

