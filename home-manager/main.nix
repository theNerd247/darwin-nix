{ 
  # Configuration for `nixpkgs`
  # TODO: refactor
  nixpkgs.config.allowUnfree = true; 

  # `home-manager` config
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.noah = import ./noah.nix;
}
