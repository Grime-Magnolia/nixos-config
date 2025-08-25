{
  description = "My NixOS configuration as a flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, hyprland, home-manager, unstable, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        # For use with `nix develop` or `nix run`
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ git nixfmt ];
        };
      }) //
    {
      nixosConfigurations = {
        nixtop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./general-conf.nix
            ./nixtop/configuration.nix
            ./nixtop/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tygo = import ./home.nix;
              home-manager.backupFileExtension = null;
            }
            {
              _module.args = {
                inherit inputs;
                unstable = import unstable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              };
            }
          ];
        };
        tynix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./general-conf.nix
            ./tynix/configuration.nix
            ./tynix/hardware-configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tygo = import ./home.nix;
              home-manager.backupFileExtension = null;
            }
            {
              _module.args = {
                inherit inputs;
                unstable = import unstable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              };
            }
          ];
        };

      };
    };
}

