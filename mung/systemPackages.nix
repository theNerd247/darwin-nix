{withSystem,...}:

{ flake.nixosModules.mung = withSystem "x86_64-linux" ({pkgs, ...}: 
  {
    
    # Future Noah: avoid putting more packages in here and instead create a
    # new nixos module for the package that way it's easier to configure.
    # 
    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs;
    [ helix 
      nixfmt-tree
      zellij
      nom
      rxvt-unicode
      git
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    ];

  });
}
