{ pkgs, ...}:

{ 

  home.sessionVariables = 
    { EDITOR = "vim";
    };

  # programs.kakoune =
  #   { enable = true;
  #   };

  # Let Home Manager install and manage itself.
  programs.home-manager =
    { enable = true;
    };

  programs.zsh = 
  {
    enable = true;
    defaultKeymap = "vicmd";
    initExtraBeforeCompInit = "export ZSH_DISABLE_COMPFIX=true";
    oh-my-zsh = 
      { 
        enable = true;
        plugins = 
        [
          "git"
        ];
      };
  };

  # programs.firefox = 
  # { enable = ! pkgs.stdenv.isDarwin;
  # };

  # programs.bash = 
  # { enable = true;
  # };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #home.stateVersion = builtins.trace config.nix.version config.nix.version;

  programs.git =
  { enable    = true;
    userEmail = "noah.harvey247 gm";
    userName  = "theNerd247";
    aliases = 
      { co   = "checkout";
        cm   = "checkout master";
        b    = "branch";
        rb   = "rebase";
        rbi  = "rebase -i";
        lgga = "log --graph --decorate --oneline --all";
        st   = "status";
      };

  }; 

  programs.vim = with pkgs.vimPlugins;
    let

      extendConfig = t: x: x // { extraConfig = x.extraConfig + "\n\n" + t; };

      extendPlugins = p: x: x // { plugins = x.plugins ++ [ p ]; };

      enableElmVim = x:
        extendPlugins elm-vim
        (extendConfig
          ''
          let g:elm_setup_keybindings = 0
          ''
          x
        );

      enableEasyAlign = x: 
        extendPlugins easy-align
        (extendConfig
          ''
          "EasyAlign
          let g:easy_align_delimiters = { '?': { 'pattern': '?' }, '(': { 'pattern': '(' }, '>': { 'pattern': '->'} }
          " start EasyAlign (visual)
          xmap ga <Plug>(EasyAlign)
          " " start EasyAlign (normal)
          nmap ga <Plug>(EasyAlign)
          ''
          x
        );

      defaultConfig = 
        { enable      = true;
          extraConfig = builtins.readFile ./init.vim;
          plugins     = [];
        };
    in
      enableElmVim (enableEasyAlign defaultConfig);
}
