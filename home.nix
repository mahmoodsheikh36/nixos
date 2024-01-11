 { config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  sxhkd_pkgs = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/b5e903cedb331f9ee268ceebffb58069f1dae9fb.tar.gz";
  }) {};
  my_sxhkd = sxhkd_pkgs.sxhkd;
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager = {
    users = let
      user_config = {
        /* the home.stateVersion option does not have a default and must be set */
        home.stateVersion = "23.05";
        programs.home-manager.enable = true;
        # home.packages = [ sxhkd ];
        services.sxhkd.enable = true;
        services.sxhkd.package = my_sxhkd;
        services.sxhkd.extraConfig = builtins.readFile(builtins.fetchurl {
          url = "https://raw.githubusercontent.com/mahmoodsheikh36/dotfiles/master/.config/sxhkd/sxhkdrc";
        });
        programs.zsh.initExtra = builtins.readFile(builtins.fetchurl {
          url = "https://raw.githubusercontent.com/mahmoodsheikh36/dotfiles/master/.zshrc";
        });
        services.syncthing.enable = true;
        programs.git = {
          enable = true;
          userName = "mahmoodsheikh36";
          userEmail = "mahmod.m2015@gmail.com";
        };
        xfconf.enable = true;
        xfconf.settings = {
          # xfce4-desktop = {
          #   "backdrop/screen0/monitorLVDS-1/workspace0/last-image" =
          #     "${pkgs.nixos-artwork.wallpapers.stripes-logo.gnomeFilePath}";
          # };
          xfce4-keyboard-shortcuts = {
            "xfwm4/custom/<Super>1" = "workspace_1_key";
            "xfwm4/custom/<Super>2" = "workspace_2_key";
            "xfwm4/custom/<Super>3" = "workspace_3_key";
            "xfwm4/custom/<Super>4" = "workspace_4_key";
            "xfwm4/custom/<Super>Tab" = "cycle_windows_key";
            "xfwm4/custom/<Super><Shift>1" = "move_window_workspace_1_key";
            "xfwm4/custom/<Super><Shift>2" = "move_window_workspace_2_key";
            "xfwm4/custom/<Super><Shift>3" = "move_window_workspace_3_key";
            "xfwm4/custom/<Super><Shift>4" = "move_window_workspace_4_key";
          };
        };
        # always clone dotfiles repository if it doesn't exist
        home.activation.dotfiles_setup = config.home-manager.users.mahmooz.lib.dag.entryAfter [ "installPackages" ] ''
          source "${config.system.build.setEnvironment}"
          $DRY_RUN_CMD curl https://raw.githubusercontent.com/mahmoodsheikh36/scripts/main/setup_dotfiles.sh | sh
        '';
        # set a variable for dotfiles repo, not necessary but convenient
        home.sessionVariables.DOTS = "/home/mahmooz/work/dotfiles";

        # temporarily, sourcehut is offline
        manual.html.enable = false;
        manual.manpages.enable = false;
        manual.json.enable = false;

        # services.fusuma = {
        #   enable = true;
        #   extraPackages = with pkgs; [ xdotool ];
        #   settings = {
        #     threshold = { swipe = 0.1; };
        #     interval = { swipe = 0.7; };
        #     # swipe = {
        #     #   "3" = {
        #     #     left = {
        #     #       # GNOME: Switch to left workspace
        #     #       command = "xdotool key ctrl+alt+Left";
        #     #     };
        #     #     right = {
        #     #       # GNOME: Switch to right workspace
        #     #       command = "xdotool key ctrl+alt+Right";
        #     #     };
        #     #   };
        #     # };
        #   };
        # };
      };
    in {
      mahmooz = user_config;
      # root = user_config;
    };
  };
}