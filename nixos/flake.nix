{
  description = "A very basic flake";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-24-11.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs-unstable, nixpkgs-24-11, ... } @ inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      tux = nixpkgs-unstable.lib.nixosSystem {
        specialArgs = { inherit system inputs; };
        modules = [ ./tux/configuration.nix ];
      };
      desktop = nixpkgs-24-11.lib.nixosSystem {
        specialArgs = { inherit system inputs; };
        modules = [ ./desktop/configuration.nix ];
      };
    };
  };
}
