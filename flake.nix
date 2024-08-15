{
  description = "nixos flake";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable; # use the unstable branch, usually behind masters by a few days
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # nixpkgs.url = github:NixOS/nixpkgs/master; # use the master branch
    home-manager.url = github:nix-community/home-manager;

    # https://github.com/gmodena/nix-flatpak?tab=readme-ov-file
    nix-flatpak.url = "github:gmodena/nix-flatpak"; # unstable branch. Use github:gmodena/nix-flatpak/?ref=<tag> to pin releases.
  };

  outputs = { self, nix-flatpak, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.mahmooz = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        nix-flatpak.nixosModules.nix-flatpak
        ./desktop.nix
      ];
    };
    homeConfigurations = {
      "mahmooz@mahmooz" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home.nix ];
      };
    };
  };
}