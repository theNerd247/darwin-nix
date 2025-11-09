{ pkgs, ... }:

let
  noah = import ./users/noah.nix;
in

## TODO: move this home manager config to it's own directory
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
      nixd
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
}
