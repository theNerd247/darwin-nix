{
  programs.helix =
  { enable = true;
    defaultEditor = true;
    settings =
      { theme = "gruvbox-material";
        editor = {
          true-color = true;
          color-modes = true;
          cursorline = true;
        };
      };
  };

  
}
