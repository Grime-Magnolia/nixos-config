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
    nixos-grub-themes.url = "github:jeslie0/nixos-grub-themes";
    stylix = {
      url = "github:nix-community/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
  };
  
  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      nixosModules = {
        flatpak = import ./modules/flatpak.nix;
      };
      customModules = builtins.attrValues self.nixosModules;
      withCustomModules = modules: modules ++ builtins.attrValues nixosModules;
      pkgsFor = system: flake: import flake {
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
      pkgs = pkgsFor system inputs.nixpkgs;
      stable = pkgsFor system inputs.nixpkgs;
      unstable = pkgsFor system inputs.unstable;
    in 
      inputs.flake-utils.lib.eachDefaultSystem (system:       
        {
          # For use with `nix develop` or `nix run`
          devShell = pkgs.mkShell {
            buildInputs = with pkgs; [ git nixfmt ];
          };
        }) // {
        packages.x86_64-linux = {
          xdna-driver = pkgs.callPackage ./packages/xdna-driver/xdna-driver.nix {
            latest= (pkgsFor system nixpkgs); inherit unstable;
          };
          xrt = pkgs.callPackage ./packages/xrt/xrt.nix {
            latest = import unstable {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          };
          mergekit = pkgs.callPackage ./packages/mergekit/mergekit.nix {
            latest = (pkgsFor system nixpkgs); inherit unstable;
          };
          vitis = pkgs.callPackage ./packages/vitis/vitis.nix {
            latest = (pkgsFor system nixpkgs); inherit unstable;
          };

        };

        nixosConfigurations = {
          nixtop = nixpkgs.lib.nixosSystem {
            inherit system;
            inherit pkgs;
            specialArgs = { inherit inputs; inherit stable; inherit unstable;};
            modules = withCustomModules [
              inputs.stylix.nixosModules.stylix
              ./modules/stylix.nix
              ./general-conf.nix
              ./modules/arrstack.nix
              ./machines/nixtop/configuration.nix
              ./machines/nixtop/hardware-configuration.nix
              inputs.home-manager.nixosModules.home-manager
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
            ];
          };
          frametop = nixpkgs.lib.nixosSystem {
            inherit system;
            inherit pkgs;
            specialArgs = { inherit inputs; inherit stable; inherit unstable;};
            modules = withCustomModules [
              inputs.stylix.nixosModules.stylix
              inputs.impermanence.nixosModules.impermanence
              inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
              ./modules/stylix.nix
              ./general-conf.nix
              ./modules/arrstack.nix
              ./machines/frametop/configuration.nix
              ./machines/frametop/hardware-configuration.nix
              inputs.home-manager.nixosModules.home-manager
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
            ];
          };
          tynix = nixpkgs.lib.nixosSystem {
            inherit system;
            inherit pkgs;
            modules = [
              inputs.stylix.nixosModules.stylix
              ./general-conf.nix
              ./modules/arrstack.nix
              ./machines/tynix/configuration.nix
              ./machines/tynix/hardware-configuration.nix
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.tygo = import ./homes/tygo/home.nix;
                home-manager.backupFileExtension = null;
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

