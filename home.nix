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
        /* The home.stateVersion option does not have a default and must be set */
        home.stateVersion = "23.05";
        # home.packages = [ sxhkd ];
        services.sxhkd.enable = true;
        services.sxhkd.package = my_sxhkd;
        services.sxhkd.extraConfig = builtins.readFile(builtins.fetchurl {
          url = "https://raw.githubusercontent.com/mahmoodsheikh36/dotfiles/master/.config/sxhkd/sxhkdrc";
        });
        services.syncthing.enable = true;
        xfconf.enable = true;
        xfconf.settings."xfce4-keyboard-shortcuts" = {
          "&lt;Super&gt;space" = "rofi -show drun";
          "<Super>space" = "rofi -show drun";
          "<Super>Tab" = "cycle_windows_key";
          "/xfwm4/custom/<Super>Tab" = "cycle_windows_key";
          "/xfwm4/custom/<Super>KP_1" = "workspace_1_key";
          "/xfwm4/custom/<Super>KP_2" = "workspace_2_key";
          "/xfwm4/custom/<Super>KP_3" = "workspace_3_key";
          "/xfwm4/custom/<Super>KP_4" = "workspace_4_key";
        };
      };
    in {
      mahmooz = user_config;
      root = user_config;
    };
  };
}
