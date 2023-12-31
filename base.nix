{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

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

  # general system config
  time.timeZone = "Asia/Jerusalem";

  # users
  users.users.mahmooz = {
    isNormalUser = true;
    extraGroups = [ "audio" ];
    shell = pkgs.zsh;
    password = "mahmooz";
  };
  security.sudo.configFile = ''
    mahmooz ALL=(ALL:ALL) NOPASSWD: ALL
  '';

  # enable some programs/services
  programs.zsh.enable = true;
  programs.adb.enable = true;
  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  services.openssh.enable = true;

  # tty configs
  console = {
    #earlySetup = true;
    font = "ter-i14b";
    packages = with pkgs; [ terminus_font ];
    useXkbConfig = true; # remap caps to escape
  };

  # setup my dotfiles
  #system.activationScripts = {
  #  setup_dotfiles = {
  #    text = ''
  #      dir=/home/mahmooz/workspace
  #      home=/home/mahmooz
  #      if [ ! -d "$dir/dotfiles" ]; then
  #        echo setting up dotfiles
  #        mkdir -p "$dir" || true
  #        cd "$dir"
  #        ${pkgs.git}/bin/git clone https://github.com/mahmoodsheikh36/dotfiles
  #        for filename in .xinitrc .zshrc .zprofile .Xresources .vimrc .emacs .tmux.conf; do
  #          ln -sf "$dir/dotfiles/$filename" "/home/mahmooz/"
  #        done

  #        mkdir "$home/.config/" || true
  #        for filename in alacritty compton.conf gtk-3.0 mimeapps.list mpv vifm qutebrowser kitty\
  #          rofi sxhkd sxiv user-dirs.dirs transmission-daemon zathura; do
  #          ln -sf "$dir/dotfiles/.config/$filename" "$home/.config/"
  #        done

  #        mkdir "$home/.config/nvim/" || true
  #        ln -sf "$dir/dotfiles/.vimrc" "$home/.config/nvim/init.vim"
  #      else
  #        echo dotfiles already setup
  #      fi
  #    '';
  #  };
  #};

  # package management
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    neovim
    curl wget nmap # networking tools

    # some helpful programs / other
    git tmux file vifm zip unzip fzf htop p7zip unrar-wrapper
    transmission gcc clang youtube-dl yt-dlp fzf acpi gnupg tree-sitter clang-tools

    # some build systems
    cmake gnumake

    # python
    (python.withPackages(ps: with ps; [
      numpy requests beautifulsoup4 flask mysql-connector
      pip redis
    ]))

    # nodejs
    nodejs nodePackages.node2nix

    # nix specific tools
    nixos-generators
    nix-prefetch-git
  ];
}
