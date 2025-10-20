{withSystem, ...}: 

{ flake.nixosModules.mung = withSystem "x86_64-linux" ({pkgs, ...}: 

  { environment.systemPackages = [ pkgs.helix ];

  # TODO: replace with home-manager module
  # programs.helix =
  #   { enable = true;
  #     defaultEditor = true;
  #     settings =
  #       { theme = "everforest_dark";
  #         editor = {
  #           true-color = true;
  #           color-modes = true;
  #           cursorline = true;
  #         };

  #         languages.nil =
  #         { formatter =
  #           { command = "nix fmt";
  #           };
  #         };
  #       };
  #   };
  });
}
