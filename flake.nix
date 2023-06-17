{
  description = "Nix-Darwin configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }:
    let
  
      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        # overlays = attrValues self.overlays ++ singleton (
        #   # Sub in x86 version of packages that don't build on Apple Silicon yet
        #   final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
        #     inherit (final.pkgs-x86)
        #       idris2
        #       nix-index
        #       niv
        #       purescript;
        #   })
        # );
      }; 

      # users information described in nix-darwin and home-manager
      noah = 
      { home = "/Users/noah";
        name = "noah";
      };
  
      # Main `nix-darwin` config
      # the default location of this nix expression is in ~/.nixpkgs/darwin-configuration.nix
      # since I'm still installing the configuration super early I don't see the need for having
      # a separate file.
      # use `darwin-rebuild switch --flake <file-path-to-this-file>` to build the darwin system
      #
      # see: https://daiderd.com/nix-darwin/manual/index.html#sec-options for config options
      darwinConfiguration = { config, pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep <program-name-query>
          environment.systemPackages =
            [ pkgs.vim
              pkgs.git
            ];
        
          # Use a custom configuration.nix location.
          # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
          # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";
        
          # Auto upgrade nix package and the daemon service.
          services.nix-daemon.enable = true;
          # nix.package = pkgs.nix;
        
          # Create /etc/zshrc that loads the nix-darwin environment.
          programs.zsh.enable = true;  # default shell on catalina
          # programs.fish.enable = true;
        
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 4;

          #NOTE: This needs to be here since nix-darwin is describing the entire system (which includes which users to setup)
          #TODO: revisit this to have a fullsetup (ssh files, etc.)
          users.users.noah = { name = noah.name; createHome = true; home = noah.home; };

          #TODO: add configuration for homebrew here 
          # include installing spectacle
        
          nix = 
          { package = pkgs.nixFlakes;
            extraOptions = 
              ''
              experimental-features = flakes nix-command
              '';
          };
        };
  
      # `home-manager` module
      # the default location for this nix expression is `~/.config/home-manager/home.nix` but
      # since the expression is so small I don't see the need to have it in a separate file yet
      # see: https://nix-community.github.io/home-manager/options.html for config options
      noahHomeConfiguration = 
        { config, pkgs, ... }:
        
        { # Home Manager needs a bit of information about you and the
          # paths it should manage.
          home = 
          { username = noah.name;
            homeDirectory = noah.home;
        
            # This value determines the Home Manager release that your
            # configuration is compatible with. This helps avoid breakage
            # when a new Home Manager release introduces backwards
            # incompatible changes.
            #
            # You can update Home Manager without changing this value. See
            # the Home Manager release notes for a list of state version
            # changes in each release.
            # TODO: it might be worth abstracting this to the top of the file?
            stateVersion = "23.05";
            packages = 
            [ pkgs.git-bug
            ];
          };
        
          # Let Home Manager install and manage itself.
          programs.home-manager.enable = false;

          programs.git =
          { enable    = true;
            userEmail = "noah.harvey247@gmail.com";
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
            extraConfig = { core = { editor = "vim"; }; };
          }; 

          programs.vim =
          { enable = true;
            extraConfig =
            ''
            " I like syntax highlighting
            " syntax enable
            " set custom colors
            "use 16 colors
            set t_Co=16 
            colorscheme default
            set background=light
            " show the commands as I type them
            set showcmd
            " don't wrap text by default
            set nowrap
            " allow for inline searching
            set incsearch
            " fold code by syntax
            set foldmethod=syntax
            " default tab size
            set tabstop=2
            " spaces to use for auto-indent
            set shiftwidth=2
            " number of spaces for a single tab
            set softtabstop=2
            set expandtab
            " show lines numbers
            set number
            set relativenumber
            " turn off smart indenting
            set nosmartindent
            set nocindent
            set noautoindent
            set indentexpr=
            " turn off spell check
            set nospell
            '';
            plugins = [];
          };
        };
  
    in
  
      { darwinConfigurations =
        { "Noahs-MBP" = darwin.lib.darwinSystem 
          { system = "aarch64-darwin";
            modules =
            [ darwinConfiguration
              home-manager.darwinModules.home-manager
              { nixpkgs = nixpkgsConfig;
                # `home-manager` config
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.noah = noahHomeConfiguration;
              }
            ];
          };
        };
      };
}
