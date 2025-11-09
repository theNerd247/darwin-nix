{ home-manager.darwinModules.home-manager =
  { 
    # Configuration for `nixpkgs`
    # TODO: refactor
    nixpkgsConfig.config.allowUnfree = true; 

    # `home-manager` config
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.noah = import ../home-manager/noah.nix;
  };
}
