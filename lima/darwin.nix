{ pkgs, ... }:
{

  imports =
  [ ../keyboard/karabiner.nix
    ../window-manager/aerospace.nix
    ../package-managers/homebrew.nix
    ./home-manager.nix
  ];
  
  documentation.doc.enable = true;

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
      HostName 192.168.1.203
    '';
  };

  # not available for darwin :(
  # networking.hosts =
  # { "192.168.1.203" = [ "mung" ];
  # };


  fonts.packages = [ pkgs.nerd-fonts.ubuntu-mono ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system = {
    stateVersion = 4;
    primaryUser = "noah";
  };

  #NOTE: This needs to be here since nix-darwin is describing the entire system (which includes which users to setup)
  #TODO: revisit this to have a fullsetup (ssh files, etc.)
  users.users.noah =
  let
      noah = import ../users/noah.nix;
  in
  { name = noah.name;
    createHome = true;
    home = noah.home;
  };

  networking.hostName = "lima";

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
}
