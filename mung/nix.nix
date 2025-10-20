{pkgs, ...}:

{ flake.nixosModules.mung = 
  {
    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    nix = 
    { package = pkgs.nix;
      # allow nix-darwin to manage the nix installation
      # see https://nix-darwin.github.io/nix-darwin/manual/index.html#opt-nix.enable
      # for more
      enable = true;
      settings = {
        trusted-users = ["noah"];
        substituters =
          [ "https://cache.nixos.org"
            "https://haskell-miso-cachix.cachix.org"
            "https://cache.iog.io"
          ];
        trusted-public-keys =
          [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
            "haskell-miso-cachix.cachix.org-1:m8hN1cvFMJtYib4tj+06xkKt5ABMSGfe8W7s40x1kQ0="
          ];
      };
      extraOptions = 
      ''
      experimental-features = flakes nix-command
      '';
    };

  };
}
