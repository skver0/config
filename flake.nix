{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-straight = {
      url = "github:codingkoi/nix-straight.el?ref=codingkoi/apply-librephoenixs-fix";
      flake = false;
    };
    nix-doom-emacs = {
      url = "github:nix-community/nix-doom-emacs";
      inputs.nix-straight.follows = "nix-straight";
    }; 
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-gaming, nix-doom-emacs, ... }: {
    nixosConfigurations = {
      
      yoi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/yoi/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.skver = import ./hosts/yoi/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
        specialArgs = { inherit inputs; };
      };

      hakudatsu = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/hakudatsu/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.skver = import ./hosts/hakudatsu/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
        specialArgs = { inherit inputs; };
       };
    };
  };
}
