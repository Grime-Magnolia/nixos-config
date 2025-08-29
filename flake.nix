{
  description = "My NixOS configuration as a flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  
  outputs = inputs@{ self, nixpkgs, flake-utils, hyprland, home-manager, unstable, ... }:
    let
      nixosModules = {
        default = import "${self}/modules/networking/mysterium-node.nix";
      };
      customModules = builtins.attrValues self.nixosModules;
      withCustomModules = modules: modules ++ builtins.attrValues nixosModules;
    in 
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays.default = final: prev: {
              myst = prev.callPackage ./custompackages/mystnode/myst.nix;
            };
            config.allowUnfree = true;
            config.permittedInsecurePackages = ["openssl-1.1.1w"];
          };
        in {
          # For use with `nix develop` or `nix run`
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [ git nixfmt ];
          };
        }) // {
        nixosConfigurations = {
          nixtop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = withCustomModules [
              ./general-conf.nix
              ./modules/homepage.nix
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
              {
                nixpkgs.config.permittedInsecurePackages = [
                  "openssl-1.1.1w"
                ];
              }
            ];
          };
          tynix = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              ./general-conf.nix
              ./modules/homepage.nix
              ./tynix/configuration.nix
              ./tynix/hardware-configuration.nix
              ./modules/homepage.nix
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
              {
                nixpkgs.config.permittedInsecurePackages = [
                  "openssl-1.1.1w"
                ];
              }
            ];
          };
        bmaxnix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./bmaxnix/configuration.nix
            ./bmaxnix/hardware-configuration.nix
            ./general-conf.nix
            {
              _module.args = {
                inherit inputs;
                unstable = import unstable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              };
            }
            {
              nixpkgs.config.permittedInsecurePackages = [
                "openssl-1.1.1w"
              ];
            }
          ];
        };
      };
  };
}

