{ flake.nixosModules.mung =
  { programs.helix =
    { enable = true;
      defaultEditor = true;
      settings =
        { theme = "everforest_dark";
          editor = {
            true-color = true;
            color-modes = true;
            cursorline = true;
          };

          languages.nil =
          { formatter =
            { command = "nix fmt";
            };
          };
        };
    };
  };
}
