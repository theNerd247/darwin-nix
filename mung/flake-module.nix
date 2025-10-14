{lib, config, ...}:
{
  flake.nixosModules.mung = import ./configuration.nix;

  flake.nixosConfigurations.mung = lib.nixosSystem
  { modules = [ config.flake.nixosModules.mung ];
  };

}
