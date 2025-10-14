{
  description = "Nix-Darwin configuration";

  inputs =
  { nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ home-manager, darwin, flake-parts, ... }:
    let
  
      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
      }; 

      # users information described in nix-darwin and home-manager
      noah = 
      { home = "/Users/noah";
        name = "noah";
        email = "noah.harvey247@gmail.com";
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
        documentation.doc.enable = false;

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep <program-name-query>
        environment = 
        { systemPackages = [];
          variables = { EDITOR = "hx"; };
          darwinConfig = "/Users/noah/.config/nix-darwin";
        };
      
        # Use a custom configuration.nix location.
        # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
        # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";
     
        # Create /etc/zshrc that loads the nix-darwin environment.
        #
        programs.zsh = {
          # NOTE: don't disable this because darwin needs the user's login shell
          # to be zsh
          enable = true;
          # This is used to keep zsh as the system shell but launch fish
          # when a new terminal env is opened
          interactiveShellInit = ''
            if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
            then
                exec fish -l
            fi
          '';
        };  # default shell on catalina

        programs.ssh =
        { # enable = true;
          extraConfig =
          ''
          Host mung
            User noah
            HostName 192.168.1.135
          '';
        };

        fonts.packages = [
          pkgs.nerd-fonts.ubuntu-mono
        ];
     
        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system = {
          stateVersion = 4;
          primaryUser = "noah";
        };

        #NOTE: This needs to be here since nix-darwin is describing the entire system (which includes which users to setup)
        #TODO: revisit this to have a fullsetup (ssh files, etc.)
        users.users.noah =
        { name = noah.name;
          createHome = true;
          home = noah.home;
        };

        networking.hostName = "judges";
        # networking.hosts =
        # { "192.168.1.135" = [ "mung" ];
        # };


        home-manager.backupFileExtension = "backup";

        #TODO: add configuration for homebrew here 
        # include installing spectacle
      
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
            stateVersion = "25.05";
            packages = with pkgs;
            [ (aspellWithDicts (d: [d.en]))
              nil
              nixfmt-rfc-style
              cachix
              nix-output-monitor
            ];

            sessionVariables = { EDITOR = "hx"; };
          };

          programs.jq.enable = true;

          programs.fish = {
            enable = true;
          };

          programs.starship = {
            enable = true;
            enableFishIntegration = true;
            enableIonIntegration = true;
            settings = {

              haskell = {
                disabled = false;
              };

              nix_shell = {
                disabled = false;
                impure_msg = "[impure shell](bold red) ";
                pure_msg = "[pure shell](bold green) ";
                unknown_msg = "[unknown shell](bold yellow) ";
                format = "via [☃️ $state( \($name\))](bold blue) ";
                heuristic = true;
              };
            };
          };
        
          # Let Home Manager install and manage itself.
          programs.home-manager = {
            enable = false;
          };

          # IRC client
          programs.irssi =
          { enable = true;
            networks =
            { liberachat = 
              { nick = "nhar"; 
                server = 
                { address = "irc.libera.chat";
                  port = 6697;
                  autoConnect = true;
                };
                channels.haskell.autoJoin = true;
              };
            };
          };

          accounts.email.accounts = 
          { personal = 
            { primary = true;
              flavor = "gmail.com";
              address = noah.email;
              realName = "Noah Harvey";
              # gpg =
              # { signByDefault = true;
              # };
              # aerc = { enable = false; };
              folders = 
                { inbox = "INBOX";
                  trash = "[Gmail]/Trash";
                  drafts = "[Gmail]/Drafts";
                  sent = "[Gmail]/Sent Mail";
                };
              himalaya =
              { enable = true; 
              };
              passwordCommand = "security find-generic-password -a noah -s gmail -w";
            };
          };

          programs.lazygit.enable = true;

          programs.himalaya = 
          { enable = true; 
            settings = {};
          };

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
            extraConfig = { core = { editor = "hx"; }; };
          }; 

          programs.helix =
          { enable = true;
            defaultEditor = true;
            settings =
              { theme = "everforest_dark";
                editor = {
                  true-color = true;
                  color-modes = true;
                  cursorline = true;
                };
              };
          };

          programs.zellij.enable = true;

          programs.vim =
          { enable = true;
            defaultEditor = false;
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
      flake-parts.lib.mkFlake { inherit inputs; } ({ config, withSystem, moduleWithSystem, ... }:
      { imports =
        [ # ./linuxConfiguration.nix
        ]; 

        systems = [ "aarch64-darwin" ];

        flake.darwinConfigurations.judges = darwin.lib.darwinSystem 
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
    });
}
