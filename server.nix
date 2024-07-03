{ config, pkgs, lib, ... }:

let
  server_vars = (import ./server_vars.nix { pkgs = pkgs; });
  per_machine_vars = (import ./per_machine_vars.nix {});
in
{
  imports =
    [
      ./hardware-configuration.nix # hardware scan results
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.tmp.cleanOnBoot = true;
  # use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;
  time.timeZone = "Asia/Jerusalem";

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

  # networking
  networking = {
    hostName = "mahmooz";
    # resolvconf.dnsExtensionMechanism = false;
    networkmanager.enable = true;
    # block some hosts by redirecting to the loopback interface
    extraHosts = ''
        127.0.0.1 youtube.com
        127.0.0.1 www.youtube.com
        # 127.0.0.1 reddit.com
        # 127.0.0.1 www.reddit.com
        127.0.0.1 discord.com
        127.0.0.1 www.discord.com
        127.0.0.1 instagram.com
        127.0.0.1 www.instagram.com
    '';
  };

  # enable some programs/services
  programs.mosh.enable = true;
  programs.zsh.enable = true;
  programs.adb.enable = true;
  services.mysql.package = pkgs.mariadb;
  programs.traceroute.enable = true;
  programs.direnv.enable = true;
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    lfs.enable = true;
  };
  programs.htop.enable = true;
  programs.iotop.enable = true;
  programs.java.enable = true;
  programs.nix-ld.enable = true;
  programs.sniffnet.enable = true;
  programs.wireshark.enable = true;
  # services.atuin.enable = true;

  services.mysql = {
    enable = true;
    settings.mysqld.bind-address = "0.0.0.0";
  };

  services.locate = {
    enable = true;
    interval = "hourly";
  };

  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
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
    pinentryPackage = lib.mkForce pkgs.pinentry;
    enableSSHSupport = true;
  };

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

  # users
  users.users.mahmooz = {
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" ];
    shell = pkgs.zsh;
    password = "mahmooz";
    packages = with pkgs; [
    ];
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
    PYTHON_HISTORY = "$HOME/brain/python_history";
    BRAIN_DIR = server_vars.brain_dir;
    MUSIC_DIR = server_vars.music_dir;
    WORK_DIR = server_vars.work_dir;
    NOTES_DIR = server_vars.notes_dir;
    SCRIPTS_DIR = server_vars.scripts_dir;
    DOTFILES_DIR = server_vars.dotfiles_dir;
    NIX_CONFIG_DIR = "$HOME/work/nixos/";
    BLOG_DIR = server_vars.blog_dir;
    QT_SCALE_FACTOR = "2";
    EDITOR = "nvim";
    BROWSER = "brave";
    LIB_PATH = "$HOME/mnt2/my/lib/:$HOME/mnt/vol1/lib/";
    MAIN_SERVER_ADDR = server_vars.main_server_addr;
    HOME_SERVER_ADDR = server_vars.home_server_addr;
    DATA_DIR = server_vars.data_dir;
    MPV_SOCKET_DIR = server_vars.mpv_socket_dir;
    MPV_MAIN_SOCKET_PATH = server_vars.mpv_main_socket_path;
    PERSONAL_WEBSITE = server_vars.personal_website;
  };

  # note that you may have to ssh first manually for the main server to be inserted into known_hosts file so that this would work
  systemd.services.my_ssh_tunnel_service = {
    description = "ssh tunnel";
    after = [ "network.target" "network-online.target" ];
    wants = [ "network-online.target" ];
    script = "${pkgs.openssh}/bin/ssh -i /home/mahmooz/brain/keys/hetzner1 -R '*:${toString per_machine_vars.remote_tunnel_port}:*:22' -6 ${server_vars.main_server_user}@${server_vars.main_server_addr} -NTg -o ServerAliveInterval=60";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "mahmooz";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "5s";
      RuntimeMaxSec = "3600";
      # Restart = "always";
    };
  };

  services.udev.extraRules = ''
    # Your rule goes here
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="777ddbd7-9692-45fb-977e-0d6678a4a213", RUN+="${pkgs.coreutils}/bin/mkdir -p /home/mahmooz/mnt" RUN+="${pkgs.systemd}/bin/systemd-mount $env{DEVNAME} /home/mahmooz/mnt/", RUN+="${lib.getExe pkgs.logger} --tag my-manual-usb-mount udev rule success, drive: %k with uuid $env{ID_FS_UUID}"
    SUBSYSTEM=="block", ENV{ID_FS_UUID}=="be5af23f-da6d-42ee-a346-5ad3af1a299a", RUN+="${pkgs.coreutils}/bin/mkdir -p /home/mahmooz/mnt2" RUN+="${pkgs.systemd}/bin/systemd-mount $env{DEVNAME} /home/mahmooz/mnt2", RUN+="${lib.getExe pkgs.logger} --tag my-manual-usb-mount udev rule success, drive: %k with uuid $env{ID_FS_UUID}"
  '';

  environment.systemPackages = server_vars.server_packages;
}
