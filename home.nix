{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
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
        programs.neovim = {
          enable = true;
          plugins = with pkgs.vimPlugins; [
            nvim-treesitter.withAllGrammars
            coc-nvim coc-css coc-explorer coc-git coc-go coc-html coc-json coc-prettier coc-pyright coc-rust-analyzer coc-tsserver coc-yaml
            coc-clangd
            coc-vimtex
            neoformat
            vim-commentary
            vim-monokai
            vimtex
            vim-nix
            vim-fugitive
          ];
          viAlias = true;
          vimAlias = true;
          vimdiffAlias = true;
          withNodeJs = true;
          withPython3 = true;
        };

        home.pointerCursor = {
          name = "Adwaita";
          package = pkgs.gnome.adwaita-icon-theme;
          size = 64;
        };

        services.blueman-applet.enable = true;

        home.packages = [
          home-manager
          (pkgs.python3.withPackages(ps: with ps; [
            matplotlib flask requests panflute numpy jupyter jupyter-core pytorch pandas sympy scipy
            scikit-learn torchvision scrapy beautifulsoup4 seaborn pillow dash mysql-connector
            rich pyspark networkx dpkt python-lsp-server #opencv
            graphviz flask-sqlalchemy flask-cors ariadne graphene nltk
          ]))
        ];

        # programs.zsh.initExtra = builtins.readFile(builtins.fetchurl {
        #   url = "https://raw.githubusercontent.com/mahmoodsheikh36/otherdots/master/.zshrc";
        # });
        # services.sxhkd.enable = true;

        services.syncthing.enable = true;

        programs.git = {
          enable = true;
          userName = "mahmoodsheikh36";
          userEmail = "mahmod.m2015@gmail.com";
        };

        xdg.desktopEntries.mympv = {
          name = "mympv";
          genericName = "mympv";
          exec = "mympv.sh %U";
          terminal = false;
          categories = [];
          # mimeType = [ "video/mp4" ];
        };


        xfconf.enable = true;
        # xfconf.settings = {
        #   # xfce4-desktop = {
        #   #   "backdrop/screen0/monitorLVDS-1/workspace0/last-image" =
        #   #     "${pkgs.nixos-artwork.wallpapers.stripes-logo.gnomeFilePath}";
        #   # };
        #   xfce4-keyboard-shortcuts = {
        #     "xfwm4/custom/<Super>1" = "workspace_1_key";
        #     "xfwm4/custom/<Super>2" = "workspace_2_key";
        #     "xfwm4/custom/<Super>3" = "workspace_3_key";
        #     "xfwm4/custom/<Super>4" = "workspace_4_key";
        #     "xfwm4/custom/<Super>Tab" = "cycle_windows_key";
        #     "xfwm4/custom/<Super><Shift>1" = "move_window_workspace_1_key";
        #     "xfwm4/custom/<Super><Shift>2" = "move_window_workspace_2_key";
        #     "xfwm4/custom/<Super><Shift>3" = "move_window_workspace_3_key";
        #     "xfwm4/custom/<Super><Shift>4" = "move_window_workspace_4_key";
        #   };
        # };

        # set a variable for dotfiles repo, not necessary but convenient
        # home.sessionVariables.DOTS = "/home/mahmooz/work/dotfiles";
        home.file = {
          # "git/config".source = ./dotfiles/git/config;
          ".config/backup/dotfiles" = {
            source = builtins.fetchGit "https://github.com/mahmoodsheikh36/dotfiles";
            onChange = "${pkgs.writeShellScript "dotfiles-change" ''
            ''}";
          };
          ".config/backup/scripts" = {
            source = builtins.fetchGit "https://github.com/mahmoodsheikh36/scripts";
          };
          ".config/backup/nixos" = {
            source = builtins.fetchGit "https://github.com/mahmoodsheikh36/nixos";
          };
          ".config/backup/otherdots" = {
            source = builtins.fetchGit "https://github.com/mahmoodsheikh36/otherdots";
          };
        };
      };
    in {
      mahmooz = user_config;
      # root = user_config;
    };
  };
}
