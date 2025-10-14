{lib, config, inputs, ...}:
{
  flake.nixosModules.mung = import ./configuration.nix;

  flake.nixosConfigurations.mung = inputs.nixpkgs.lib.nixosSystem
  { modules = [ config.flake.nixosModules.mung ];
  };

}
