{
  description = "My NixOS configuration as a flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "github:hyprwm/Hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };
  
  outputs = inputs@{ self, nixpkgs, impermanence, stylix, nixos-hardware, flake-utils, hyprland, home-manager, unstable, ... }:
    let
      system = "x86_64-linux";
      nixosModules = {
        flatpak = import ./modules/flatpak.nix;
      };
      customModules = builtins.attrValues self.nixosModules;
      withCustomModules = modules: modules ++ builtins.attrValues nixosModules;
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [
          (import ./overlays/yt-dlp.nix)
          (import ./overlays/freac.nix)
        ];
        config.allowUnfree = true;
        config.permittedInsecurePackages = [
          "openssl-1.1.1w"
          "mbedtls-2.28.10"
        ];
      };
      pkgs = pkgsFor system;
    in 
      flake-utils.lib.eachDefaultSystem (system:       
        {
          # For use with `nix develop` or `nix run`
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [ git nixfmt ];
          };
        }) // {
        packages.x86_64-linux = {
          xdna-driver = pkgs.callPackage ./packages/xdna-driver/xdna-driver.nix {
            latest=import unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          xrt = pkgs.callPackage ./packages/xrt/xrt.nix {
            latest = import unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
        };

        nixosConfigurations = {
          nixtop = nixpkgs.lib.nixosSystem {
            inherit system;
            inherit pkgs;
            modules = withCustomModules [
              stylix.nixosModules.stylix
              ./modules/stylix.nix
              ./general-conf.nix
              ./modules/arrstack.nix
              ./machines/nixtop/configuration.nix
              ./machines/nixtop/hardware-configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.tygo = {
                  imports = [
                    ./homes/tygo/home.nix
                  ];
                };
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
          frametop = nixpkgs.lib.nixosSystem {
            inherit system;
            inherit pkgs;
            modules = withCustomModules [
              stylix.nixosModules.stylix
              impermanence.nixosModules.impermanence
              nixos-hardware.nixosModules.framework-amd-ai-300-series
              ./modules/stylix.nix
              ./general-conf.nix
              ./modules/arrstack.nix
              ./machines/frametop/configuration.nix
              ./machines/frametop/hardware-configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.tygo = {
                  imports = [
                    ./homes/tygo/home.nix
                  ];
                };
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
            inherit system;
            inherit pkgs;
            modules = [
              stylix.nixosModules.stylix
              ./general-conf.nix
              ./modules/arrstack.nix
              ./machines/tynix/configuration.nix
              ./machines/tynix/hardware-configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.tygo = import ./homes/tygo/home.nix;
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
        bmaxnix = nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
          modules = [
            ./machines/bmaxnix/configuration.nix
            ./machines/bmaxnix/hardware-configuration.nix
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
          ];
        };
      };
  };
}

