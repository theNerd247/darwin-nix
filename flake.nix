{
  description = "Nix-Darwin configuration";

  inputs =
  { nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

  };

  outputs = inputs@{ nix-darwin, flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ ... }:
      { imports =
        [ (import-tree ./mung)
          (import-tree ./modules)
        ]; 

        systems = [ "aarch64-darwin" ];

        flake.darwinConfigurations.lima = nix-darwin.lib.darwinSystem 
        { system = "aarch64-darwin";
          modules =
          [ ./lima/darwin.nix 
            inputs.home-manager.darwinModules.home-manager
          ];
        };
    });
}
