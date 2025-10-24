{config, inputs, ...}:
{
  # the config.flake.nixosModules is the result of monoidal actions
  # across all flake.nixosModules.mung values that are imported in
  # flake.nix
  flake.nixosConfigurations.mung = inputs.nixpkgs.lib.nixosSystem
  { modules =
    [ config.flake.nixosModules.mung
      ./_hardware-configuration.nix
      ./modules/_kitty.nix
    ];
  };

}
