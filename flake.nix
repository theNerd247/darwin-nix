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

  outputs = inputs@{ home-manager, nix-darwin, flake-parts, import-tree, ... }:
    let
        # Configuration for `nixpkgs`
      nixpkgsConfig.config.allowUnfree = true; 

      # Main `nix-darwin` config
      # the default location of this nix expression is in ~/.nixpkgs/darwin-configuration.nix
      # since I'm still installing the configuration super early I don't see the need for having
      # a separate file.
      # use `darwin-rebuild switch --flake <file-path-to-this-file>` to build the darwin system
      #
      # see: https://daiderd.com/nix-darwin/manual/index.html#sec-options for config options
      darwinConfiguration = import ./lima/darwin.nix;

      # `home-manager` module
      # the default location for this nix expression is `~/.config/home-manager/home.nix` but
      # since the expression is so small I don't see the need to have it in a separate file yet
      # see: https://nix-community.github.io/home-manager/options.html for config options
      noahHomeConfiguration = import ./noahDarwinHome.nix;

    in
      flake-parts.lib.mkFlake { inherit inputs; } ({ ... }:
      { imports =
        [ (import-tree ./mung)
          (import-tree ./modules)
        ]; 

        systems = [ "aarch64-darwin" ];

        flake.darwinConfigurations.lima = nix-darwin.lib.darwinSystem 
        { system = "aarch64-darwin";
          modules =
          [ darwinConfiguration
            home-manager.darwinModules.home-manager
            { nixpkgs = nixpkgsConfig;
              # `home-manager` config
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.noah = noahHomeConfiguration;
            }
          ];
        };
    });
}
