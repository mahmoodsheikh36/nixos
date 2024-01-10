{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # hardware scan results
      ./home.nix # home-manager etc
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
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;
  services.iptsd.enable = true;
  services.iptsd.config.Touch.DisableOnStylus = true;

  # temporarily, sourcehut is offline
  manual.{html,manpages,json}.enable = false;

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
    (import (builtins.fetchTarball { # emacs master
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
    (self: super:
    {
      my_emacs = super.emacs-git.overrideAttrs (oldAttrs: rec {
        # src = super.fetchFromGitHub {
        #   owner = "emacs-mirror";
        #   repo = "emacs";
        #   rev = "4939f4139391c13c34387ac0c05a5c7db39bf9d5";
        #   sha256 = "0k34blhvpc58s0ahgdc6lhv02fia6yf2x5agmk96xn6m67mkcmbc";
        # };
        configureFlags = oldAttrs.configureFlags ++ ["--with-json" "--with-tree-sitter" "--with-native-compilation" "--with-modules"]; # --with-widgets "--with-imagemagick"
        patches = [];
        imagemagick = pkgs.imagemagickBig;
        withImageMagick = true;
      });
    })
  ];

  services.emacs = {
    enable = true;
    package = pkgs.my_emacs; # pkgs.emacsGit;
  };

  # x11 and awesomewm
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        tappingDragLock = false;
        accelSpeed = "0.7";
        naturalScrolling = false;
      };
    };
    layout = "us";
    xkbOptions = "caps:swapescape,ctrl:ralt_rctrl";
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = false;
      };
      setupCommands = ''
        sxhkd &
        # feh --bg-fill ~/.cache/wallpaper
        ${pkgs.hsetroot}/bin/hsetroot -solid '#222222'
      '';
      autoLogin.enable = true;
      autoLogin.user = "mahmooz";
      startx.enable = true;
      sx.enable = true;
      defaultSession = "none+awesome";
      # defaultSession = "xfce+awesome";
      # defaultSession = "xfce";
      # defaultSession = "gnome";
    };
    windowManager.awesome = {
      package = with pkgs; my_awesome;
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
    # desktopManager.gnome.enable = true;
    desktopManager = {
      xfce = {
        enable = true;
        noDesktop = false;
        enableXfwm = true;
      };
    };
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # gnome configs
  services.gnome.tracker.enable = false;
  services.gnome.tracker-miners.enable = false;
  # a workaround for auto login issue
  # systemd.services."mahmooz@tty1".enable = false;

  # tty configs
  console = {
    #earlySetup = true;
    font = "ter-i14b";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # remap caps to escape
  };
  # security.sudo.extraConfig = ''
  #   mahmooz ALL=(ALL:ALL) NOPASSWD: ALL
  # '';
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };
  security.polkit.enable = true;

  time.timeZone = "Asia/Jerusalem";

  # ask for password in terminal instead of x11-ash-askpass
  programs.ssh.askPassword = "";

  # networking
  networking = {
    hostName = "mahmooz";
    enableIPv6 = false;
    resolvconf.dnsExtensionMechanism = false;
    networkmanager.enable = true;
    # block some hosts by redirecting to the loopback interface
    extraHosts = ''
        192.168.1.150 server
        127.0.0.1 youtube.com
        127.0.0.1 www.youtube.com
        # 127.0.0.1 reddit.com
        # 127.0.0.1 www.reddit.com
        # 127.0.0.1 discord.com
        # 127.0.0.1 www.discord.com
        127.0.0.1 instagram.com
        127.0.0.1 www.instagram.com
    '';
  };

  # enable some programs/services
  programs.zsh.enable = true;
  programs.adb.enable = true;
  services.printing.enable = true; # CUPS
  services.flatpak.enable = true;
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.openssh.enable = true;
  services.touchegg.enable = true;
  programs.traceroute.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
      thunar-volman
    ];
  };
  programs.firefox.enable = true;
  programs.xfconf.enable = true;
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # Generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
      '';
    # ensureDatabases = [ "mydatabase" ];
    # port = 5432;
    # initialScript = pkgs.writeText "backend-initScript" ''
    #   CREATE ROLE mahmooz WITH LOGIN PASSWORD 'mahmooz' CREATEDB;
    # '';
  };
  programs.direnv.enable = true;
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
  };
  programs.htop.enable = true;
  programs.java.enable = true;
  programs.neovim.enable = true;
  programs.nix-ld.enable = true;
  programs.nm-applet.enable = true;
  programs.sniffnet.enable = true;
  programs.virt-manager.enable = true;
  programs.wireshark.enable = true;
  qt.enable = true;

  programs.nix-index = { # helps finding the package that contains a specific file
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };
  programs.command-not-found.enable = false; # needed for nix-index

  # gpg
  services.pcscd.enable = true;
  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor = "curses";
     enableSSHSupport = true;
  };

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
  environment.wordlist.enable = true;

  # packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # text editors
    # emacs29
    vscode
    vim

    # media tools
    mpv
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
    popcorntime
    lollypop
    clementine

    # media manipulation tools
    imagemagickBig ghostscript # ghostscript is needed for some imagemagick commands
    ffmpeg
    gimp inkscape

    # general tools
    google-chrome qutebrowser tor-browser-bundle-bin
    scrcpy
    pavucontrol
    libreoffice
    syncthing

    # commandline tools
    kitty # terminal emulator
    pulsemixer # tui for pulseaudio control
    playerctl # media control
    sqlite
    gptfdisk parted
    silver-searcher # the silver searcher i use it for emacs
    libtool # to compile vterm
    xdotool
    docker
    jq
    ripgrep
    pdftk pdfgrep
    spotdl
    parallel

    # x11 tools
    rofi
    libnotify
    xclip
    scrot
    picom
    parcellite
    hsetroot
    unclutter
    xorg.xev

    # other
    redis
    zoom-us
    hugo
    adb-sync
    woeusb-ng
    ntfs3g
    gnupg1orig
    pigz pinentry
    SDL2
    sass
    simplescreenrecorder

    # virtualization tools
    qemu virt-manager

    # science
    gnuplot
    # sageWithDoc sagetex

    # some programming languages/environments
    lua
    openjdk
    flutter dart android-studio
    texlive.combined.scheme-full
    rustc meson ninja
    jupyter
    typescript
    (python310.withPackages(ps: with ps; [
      matplotlib flask requests panflute numpy jupyter jupyter-core pytorch pandas sympy scipy
      scikit-learn torchvision opencv scrapy beautifulsoup4 seaborn pillow dash mysql-connector
      rich pyspark networkx
    ]))
    (julia.withPackages([
      "Plots" "Graphs" "CSV" "NetworkLayout" "SGtSNEpi" "Karnak" "DataFrames"
      "TikzPictures" "Gadfly" "Makie" "Turing" "RecipesPipeline"
      "LightGraphs" "JET" "HTTP" "LoopVectorization" "OhMyREPL" "MLJ"
      "Luxor" "ReinforcementLearningBase" "Images" "Flux" "DataStructures" "RecipesBase"
      "Latexify" "Distributions" "StatsPlots" "Gen" "Zygote" "UnicodePlots"
      # "Optimization" "ForwardDiff"
      # "Transformers" "ModelingToolkit" "WaterLily" "Knet" "CUDA" "Javis" "Weave" "GalacticOptim" "BrainFlow" "Genie" "Dagger" "Interact" "StaticArrays" "Symbolics" "SymbolicUtils"
    ]))
    sbcl
    racket
    gcc clang gdb clang-tools

    zeal devdocs-desktop

    # networking tools
    curl wget nmap socat arp-scan tcpdump

    # some helpful programs / other
    tmux file vifm zip unzip fzf p7zip unrar-wrapper
    transmission yt-dlp acpi gnupg tree-sitter
    cryptsetup
    onboard # onscreen keyboard
    spark
    openssl

    # some build systems
    cmake gnumake

    # nodejs
    nodejs nodePackages.node2nix

    # nix specific tools
    nixos-generators
    nix-prefetch-git

    # dictionary
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
  ];

  # monitoring services
  services.grafana = {
    enable = true;
    settings.server.http_port = 2342;
    settings.server.domain =  "grafana.pele";
    settings.server.addr = "127.0.0.1";
  };
  # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
    };
  };
  services.prometheus = {
    enable = true;
    port = 9001;
  };
  # services.monit.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05"; # dont change
}