{ config, pkgs, ... }:

let
  desktop_vars = (import ./desktop_vars.nix { pkgs = pkgs; });
in
{
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
        services.playerctld.enable = true;
        services.parcellite.enable = true;

        home.packages = [
        ];

        programs.git = {
          enable = true;
          userName = "mahmoodsheikh36";
          userEmail = "mahmod.m2015@gmail.com";
        };

        xdg.desktopEntries.mympv = {
          name = "mympv";
          genericName = "mympv";
          exec = "mympv.sh %F";
          terminal = false;
          categories = [];
          # mimeType = [ "video/mp4" ];
        };
        xdg.desktopEntries.add_magnet = {
          name = "add_magnet";
          genericName = "add_magnet";
          exec = "add_magnet.sh \"%F\"";
          terminal = false;
          categories = [];
          mimeType = [ "x-scheme-handler/magnet" ];
        };

        # set a variable for dotfiles repo, not necessary but convenient
        # home.sessionVariables.DOTS = "/home/mahmooz/work/dotfiles";
        # home.file = {
        #   # "git/config".source = ./dotfiles/git/config;
        #   ".config/backup/dotfiles" = {
        #     source = builtins.fetchGit "https://github.com/mahmoodsheikh36/dotfiles";
        #     onChange = "${pkgs.writeShellScript "dotfiles-change" ''
        #     ''}";
        #   };
        #   ".config/backup/scripts" = {
        #     source = builtins.fetchGit "https://github.com/mahmoodsheikh36/scripts";
        #   };
        #   ".config/backup/nixos" = {
        #     source = builtins.fetchGit "https://github.com/mahmoodsheikh36/nixos";
        #   };
        #   ".config/backup/otherdots" = {
        #     source = builtins.fetchGit "https://github.com/mahmoodsheikh36/otherdots";
        #   };
        # };
      };
    in {
      mahmooz = user_config;
      # root = user_config;
    };
  };
}