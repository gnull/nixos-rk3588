{
  description = "NixOS configuration for RK3588";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # This is temporary, until https://github.com/NixOS/nixpkgs/pull/477779 is fixed:
    gnull.url = "github:gnull/nixpkgs/patch-1";
  };

  outputs =
    { self, nixpkgs, flake-utils, gnull, ... }:
    {
      ## System config, use with nixos-rebuild
      nixosConfigurations = {
        orangepi5plus = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./sdcard.nix
            ./hardware-configuration.nix
            ./configuration.nix
          ];
          specialArgs = {
            inherit nixpkgs;
            inherit gnull;
          };
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
    {
      packages = {
        sdImage = self.nixosConfigurations.orangepi5plus.config.system.build.sdImage;
      };
    });
}
