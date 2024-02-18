{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # hardware scan results
      ./home.nix # home-manager etc
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.cleanOnBoot = true;
  # use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # enable sound and bluetooth
  # services.blueman.enable = true;
  # hardware.bluetooth = {
  #   enable = true;
  #   settings = {
  #     General = {
  #       Enable = "Source,Sink,Media,Socket";
  #       Experimental = true;
  #     };
  #     Policy = {
  #       AutoEnable = "true";
  #     };
  #   };
  #   powerOnBoot = true;
  # };
  # hardware.pulseaudio = {
  #   enable = true;
  #   #extraModules = [ pkgs.pulseaudio-modules-bt ];
  #   package = pkgs.pulseaudioFull;
  #   extraConfig = "
  #     load-module module-switch-on-connect
  #   ";
  # };
  hardware.pulseaudio.enable = false;
  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  environment.etc = {
    "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
      bluez_monitor.properties = {
        ["bluez5.enable-sbc-xq"] = true,
        ["bluez5.enable-msbc"] = true,
        ["bluez5.enable-hw-volume"] = true,
        ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
      }
    '';
  };

  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;
  services.iptsd.enable = true;
  services.iptsd.config.Touch.DisableOnStylus = true;

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
      my_emacs_git = super.emacs-git.overrideAttrs (oldAttrs: rec {
        # src = super.fetchFromGitHub {
        #   owner = "emacs-mirror";
        #   repo = "emacs";
        #   rev = "4939f4139391c13c34387ac0c05a5c7db39bf9d5";
        #   sha256 = "0k34blhvpc58s0ahgdc6lhv02fia6yf2x5agmk96xn6m67mkcmbc";
        # };
        configureFlags = oldAttrs.configureFlags ++ ["--with-json" "--with-tree-sitter" "--with-native-compilation" "--with-modules" "--with-widgets" "--with-imagemagick"];
        patches = [];
        imagemagick = pkgs.imagemagickBig;
      });
    })
    (self: super: {
      my_emacs = (super.emacs.override { withImageMagick = true; withXwidgets = true; withGTK3 = true; withNativeCompilation = true; withCompressInstall=false; withTreeSitter=true; }).overrideAttrs (oldAttrs: rec {
        # src = super.fetchFromGitHub {
        #   owner = "emacs-mirror";
        #   repo = "emacs";
        #   rev = "4939f4139391c13c34387ac0c05a5c7db39bf9d5";
        #   sha256 = "0k34blhvpc58s0ahgdc6lhv02fia6yf2x5agmk96xn6m67mkcmbc";
        # };
        #configureFlags = oldAttrs.configureFlags ++ [
          #"--with-tree-sitter"
          #"--with-gnutls"
          #"--with-xwidgets"
          #"--with-sqlite3=no"
          #"--with-native-compilation=no"
          #"--with-png"
          #"--with-gif"
          #"--with-jpeg"
          #"--with-sound"
          #"--with-libsystemd"
          #"--with-harfbuzz"
          #"--with-dbus"
          #"--with-sound"
          #"--with-file-notification=yes"
          #"--with-wide-int"
          #"--with-pdumper=yes"
          #"--with-small-ja-dic"
          #"--without-compress-install"

          #"--with-imagemagick"
          #"--with-modules"
          #"--with-json"
          #"--with-widgets"
        #];
        #patches = [];
        imagemagick = pkgs.imagemagickBig;
      });
    })
  ];

  #services.emacs = {
    ## enable = true;
    #package = pkgs.my_emacs; # pkgs.emacsGit;
  #};

  # x11 and awesomewm
  services.xserver = {
    enable = true;
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        tappingDragLock = false;
        accelSpeed = "0.9";
        naturalScrolling = false;
      };
    };
    xkb.layout = "us";
    xkb.options = "caps:escape,ctrl:ralt_rctrl";
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = false;
      };
      setupCommands = ''
        # ${pkgs.feh}/bin/feh --bg-fill ~/.cache/wallpaper
        ${lib.getExe pkgs.hsetroot} -solid '#222222'
        # ${lib.getExe pkgs.sxhkd}
        ${lib.getExe pkgs.xorg.xrdb} -load ~/.Xresources
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
    desktopManager = {
      gnome.enable = true;
      plasma5.enable = true;
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
    # extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    # config.common.default = "*";
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
        # 127.0.0.1 youtube.com
        # 127.0.0.1 www.youtube.com
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
  programs.xfconf.enable = true;
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
      '';
    package = pkgs.postgresql_16;
    ensureDatabases = [ "mahmooz" ];
    # port = 5432;
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE mahmooz WITH LOGIN PASSWORD 'mahmooz' CREATEDB;
      CREATE DATABASE test;
      GRANT ALL PRIVILEGES ON DATABASE test TO mahmooz;
    '';
    ensureUsers = [{
      name = "mahmooz";
      ensureDBOwnership = true;
    }];
  };
  programs.direnv.enable = true;
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
  };
  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.java.enable = true;
  programs.neovim.enable = true;
  programs.nix-ld.enable = true;
  #programs.nm-applet.enable = true; # this thing is annoying lol (send notifications and stuff..)
  programs.sniffnet.enable = true;
  programs.virt-manager.enable = true;
  programs.wireshark.enable = true;
  programs.dconf.enable = true;
  programs.firefox.enable = true;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  services.locate = {
    enable = true;
    # pkg = pkgs.mlocate;
    interval = "hourly";
  };

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
      #google-fonts
      cascadia-code
      inconsolata-nerdfont
      iosevka
      fira-code
      nerdfonts
      ubuntu_font_family
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      # persian font
      vazir-fonts
      font-awesome
      # corefonts # MS fonts?
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      dejavu_fonts
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
    emacs29
    vscode

    # media tools
    mpv
    feh # i use it to set wallpaper
    discord
    my_sxiv
    telegram-desktop
    zoom-us
    youtube-music
    okular pandoc zathura
    xournalpp gnome.adwaita-icon-theme # the icon theme is needed for xournalpp to work otherwise it crashes
    krita
    ocrmypdf pdftk pdfgrep poppler_utils calibre
    popcorntime
    lollypop clementine
    djvulibre

    # media manipulation tools
    imagemagickBig ghostscript # ghostscript is needed for some imagemagick commands
    ffmpeg-full.bin
    gimp inkscape

    # general tools
    google-chrome tor-browser-bundle-bin # qutebrowser
    scrcpy
    pavucontrol
    libreoffice
    syncthing

    # commandline tools
    kitty wezterm # terminal emulator
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
    spotdl
    parallel
    pigz

    # x11 tools
    rofi
    libnotify
    xclip
    maim # maim is a better alternative to scrot
    picom
    parcellite
    hsetroot
    unclutter
    xorg.xev
    sxhkd

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
    ncdu dua duf dust
    usbutils
    pciutils
    subversion # git alternative
    logseq

    # virtualization tools
    qemu virt-manager

    # science
    gnuplot
    sageWithDoc sagetex

    # some programming languages/environments
    lua
    openjdk
    flutter dart android-studio
    texlive.combined.scheme-full
    rustc meson ninja
    jupyter
    typescript
    (julia.withPackages.override({ precompile = false; })([
      "TruthTables" "LinearSolve"
      "Plots" "Graphs" "CSV" "NetworkLayout" "SGtSNEpi" "Karnak" "DataFrames"
      "TikzPictures" "Gadfly" "Makie" "Turing" "RecipesPipeline"
      "LightGraphs" "JET" "HTTP" "LoopVectorization" "OhMyREPL" "MLJ"
      "Luxor" "ReinforcementLearningBase" "Images" "Flux" "DataStructures" "RecipesBase"
      "Latexify" "Distributions" "StatsPlots" "Gen" "Zygote" "UnicodePlots" "StaticArrays"
      "Weave" "BrainFlow" "Genie" "WaterLily"
      "Symbolics" "SymbolicUtils" "ForwardDiff" "Metatheory" "TermInterface" "SymbolicRegression"
      # "Optimization" "Knet" "ModelingToolkit"
      # "Transformers" "CUDA" "Javis" "GalacticOptim" "Dagger" "Interact"
    ]))
    racket
    gcc clang gdb clang-tools
    python311Packages.west

    # lisps
    lispPackages.quicklisp
    (sbcl.withPackages (ps: with ps; [
      lem-opengl
      serapeum
      lparallel
      cl-csv
      hunchentoot
      jsown
    ]))
    # usage example:
    # $ sbcl
    # * (load (sb-ext:posix-getenv "ASDF"))
    # * (asdf:load-system 'alexandria)
    babashka

    # offline docs
    zeal devdocs-desktop

    # networking tools
    curl wget nmap socat arp-scan tcpdump

    # some helpful programs / other
    tmux file vifm zip unzip fzf p7zip unrar-wrapper
    transmission acpi gnupg tree-sitter lm_sensors
    cryptsetup
    onboard # onscreen keyboard
    spark
    openssl
    haskellPackages.kmonad xcape keyd # keyboard utilities
    pulseaudioFull
    yt-dlp you-get

    # some build systems
    cmake gnumake autoconf

    # nodejs
    nodejs nodePackages.node2nix

    # nix specific tools
    nixos-generators
    nix-prefetch-git

    # dictionary
    (aspellWithDicts (dicts: with dicts; [ en en-computers en-science ]))
    # enchant.dev # for emacs jinx-mode

    (emacsWithPackagesFromUsePackage {
      config = "/dev/null";
      # substitution:
      #   defaultInitFile = pkgs.substituteAll {
      #     name = "default.el";
      #     src = ./emacs.el;
      #     inherit (config.xdg) configHome dataHome;
      #   };
      defaultInitFile = false;
      package = my_emacs; # emacs-git;
      alwaysEnsure = true;
      extraEmacsPackages = epkgs: [
        epkgs.cask
        # epkgs.jinx
      ];
      # Optionally override derivations.
      # override = final: prev: {
      #   weechat = prev.melpaPackages.weechat.overrideAttrs(old: {
      #     patches = [ ./weechat-el.patch ];
      #   });
      # };
    })
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

  # run sxhkd when x11 starts
  systemd.user.services.my_sxhkd_service = {
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      #Type = "dbus";
      #BusName = "org.freedesktop.Notifications";
      ExecStart = "${lib.getExe pkgs.sxhkd}";
    };
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME   = "$HOME/.local/share";
    XDG_STATE_HOME  = "$HOME/.local/state";
    # not officially in the specification
    XDG_BIN_HOME    = "$HOME/.local/bin";
    PATH = [ 
      "${XDG_BIN_HOME}"
    ];
    # this one fixes some problems with python matplotlib and probably some other qt applications
    QT_QPA_PLATFORM_PLUGIN_PATH = "${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins";
    PYTHON_HISTORY_FILE = "$HOME/brain/python_history";
    BRAIN_DIR = "$HOME/brain";
    MUSIC_DIR = "$HOME/music";
    SCRIPTS_DIR = "$HOME/work/scripts/";
    DOTFILES_DIR = "$HOME/work/otherdots/";
    QT_SCALE_FACTOR = "2";
    EDITOR = "nvim";
  };

  # environment.variables = {
  #   # for the emacs jinx-mode package, needs to compile a .c file that includes enchant.h
  #   CPLUS_INCLUDE_PATH = "${pkgs.enchant.dev}/include";
  #   C_INCLUDE_PATH = "${pkgs.enchant.dev}/include";
  #   LIBRARY_PATH = "${pkgs.enchant}/lib";
  # };

  # packages cache
  nix = {
    settings = {
      substituters = [
        "https://nix-community.cachix.org"
        "https://nixpkgs-update.cachix.org"
        "https://cache.nixos.org/"
        "https://nix-gaming.cachix.org"
        "https://chaotic-nyx.cachix.org"
        "https://ezkea.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6/+Iy8eZX2ajf09e4EE9SnxSML1W8="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "nyx.chaotic.cx-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
      ];
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.05"; # dont change
}