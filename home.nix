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
        # services.syncthing.enable = true;
        xfconf.enable = true;
        xfconf.settings = {
          xfce4-desktop = {
            "backdrop/screen0/monitorLVDS-1/workspace0/last-image" =
              "${pkgs.nixos-artwork.wallpapers.stripes-logo.gnomeFilePath}";
          };
          xfce4-keyboard-shortcuts = {
            "xfwm4/custom/<Super>1" = "workspace_1_key";
            "xfwm4/custom/<Super>2" = "workspace_2_key";
            "xfwm4/custom/<Super>3" = "workspace_3_key";
            "xfwm4/custom/<Super>4" = "workspace_4_key";
            "xfwm4/custom/<Super>Tab" = "cycle_windows_key";
          };
        };
        services.fusuma = {
          enable = true;
          extraPackages = with pkgs; [ xdotool ];
          settings = {
            threshold = { swipe = 0.1; };
            interval = { swipe = 0.7; };
            swipe = {
              "3" = {
                left = {
                  # GNOME: Switch to left workspace
                  command = "xdotool key ctrl+alt+Left";
                };
                right = {
                  # GNOME: Switch to right workspace
                  command = "xdotool key ctrl+alt+Right";
                };
              };
            };
          };
        };
      };
    in {
      mahmooz = user_config;
      # root = user_config;
    };
  };
}