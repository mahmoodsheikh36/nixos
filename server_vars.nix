{ pkgs, ... }: rec {

  server_overlays = [
    (import (builtins.fetchTarball { # emacs master
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
      sha256 = "0hh1vwy4dlxq8mj4vh1q1346y3n10zimj53ifh83j4s9mcc578ja"; # to avoid an error
    }))
    # (self: super:
    #   {
    #     my_emacs_git = super.emacs-git.overrideAttrs (oldAttrs: rec {
    #       configureFlags = oldAttrs.configureFlags ++ ["--with-json" "--with-tree-sitter" "--with-native-compilation" "--with-modules" "--with-widgets" "--with-imagemagick"];
    #       patches = [];
    #       imagemagick = pkgs.imagemagickBig;
    #     });
    #   })
    (self: super: {
      my_emacs_git = (super.emacs-git.override { withImageMagick = true; withXwidgets = true; withGTK3 = true; withNativeCompilation = true; withCompressInstall = false; withTreeSitter = true; }).overrideAttrs (oldAttrs: rec {
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
    ffmpeg-full.bin untrunc-anthwlock
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
    inetutils ncftp

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

    # nix specific tools
    nixos-generators
    nix-prefetch-git
    deploy-rs
    nix-tree

    # my_emacs
    my_emacs_git
  ];

  main_server_addr = "2a01:4f9:c012:ad1b::1";
  main_server_user = "root";
  home_server_addr = "192.168.1.150";
  main_user = "mahmooz";
  home_dir = "/home/mahmooz";
  work_dir = "/home/${main_user}/work";
  scripts_dir = "${work_dir}/scripts";
  dotfiles_dir = "${work_dir}/otherdots";
  blog_dir = "${work_dir}/blog";
  brain_dir = "${home_dir}/brain";
  music_dir = "${home_dir}/music";
  notes_dir = "${brain_dir}/notes";
  data_dir = "${home_dir}/data";
  mpv_socket_dir = "${data_dir}/mpv_data/sockets";
  mpv_main_socket_path = "${data_dir}/mpv_data/sockets/mpv.socket";
  personal_website = "https://mahmoodsheikh36.github.io";
}