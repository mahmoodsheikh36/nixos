{
  description = "nixos flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    home-manager.url = github:nix-community/home-manager;
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.mahmooz = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };
      modules = [
        ./desktop.nix
      ];
    };
    homeConfigurations = {
      # FIXME replace with your username@hostname
      "mahmooz@mahmooz" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        # > Our main home-manager configuration file <
        modules = [ ./home.nix ];
      };
    };
  };
}