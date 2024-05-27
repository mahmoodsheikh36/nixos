{ pkgs, ... }: {

  server_overlays = [
    (import (builtins.fetchTarball { # emacs master
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      sha256 = "1h8glxvkqvjvp1d3gi49q7swj5xi6456vw5xj5h9mrbfzgqn7ihg"; # to avoid an error
    }))
    (self: super:
      {
        my_emacs_git = super.emacs-git.overrideAttrs (oldAttrs: rec {
          configureFlags = oldAttrs.configureFlags ++ ["--with-json" "--with-tree-sitter" "--with-native-compilation" "--with-modules" "--with-widgets" "--with-imagemagick"];
          patches = [];
          imagemagick = pkgs.imagemagickBig;
        });
      })
    (self: super: {
      my_emacs = (super.emacs.override { withImageMagick = true; withXwidgets = true; withGTK3 = true; withNativeCompilation = true; withCompressInstall=false; withTreeSitter=true; }).overrideAttrs (oldAttrs: rec {
        imagemagick = pkgs.imagemagickBig;
      });
    })
  ];

  server_packages = with pkgs; [
    pandoc
    imagemagickBig ghostscript # ghostscript is needed for some imagemagick commands
    ffmpeg-full.bin
    sqlite
    silver-searcher
    docker
    jq
    ripgrep
    spotdl
    parallel
    pigz
    fd # alternative to find
    sshfs
    dash
    redis
    ncdu dua duf dust # file size checkers i think
    btop
    lshw
    lsof
    exiftool
    distrobox

    openjdk
    gcc clang gdb clang-tools

    # networking tools
    curl wget nmap socat arp-scan tcpdump

    file vifm zip unzip fzf p7zip unrar-wrapper
    transmission acpi gnupg tree-sitter lm_sensors
    cryptsetup
    openssl
    yt-dlp you-get
    aria # aria2c downloader
    pls # alternative to ls
    man-pages man-pages-posix
    ansible
    bc # for arithmetic in shell
    ttags
    diffsitter

    # some build systems
    cmake gnumake autoconf
    pkg-config

    # nodejs
    nodejs
    yarn

    emacs
  ];

  main_server_addr = "2a01:4f9:c012:ad1b::1";
  main_server_user = "root";
}