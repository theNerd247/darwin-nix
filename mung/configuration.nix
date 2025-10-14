# nixox configuration for the mung server
{pkgs, ...}:

{ imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  config =
  { nix = 
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

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # enable ntfs support
    boot.supportedFilesystems = [ "exfat" ];

    fileSystems."/mnt/backup" =
    { device = "/dev/disk/by-uuid/E841-9F80";
      fsType = "exfat";
      options = [ "rw" "uid=1000"];
    };


    # what to do when on battery and the laptop is closed
    services.logind.lidSwitch = "suspend";
    # what to do when on plugged in and the laptop is closed
    services.logind.lidSwitchExternalPower = "ignore";
    # what to do when on plugged in and connected to another monitor and  the laptop is closed
    services.logind.lidSwitchDocked = "ignore";

    networking.hostName = "mung"; # Define your hostname.
    networking.hosts =
    { "192.168.1.49" = [ "lima" ];
    };
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "America/Los_Angeles";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # this is used to have x11 forwarding
    #
    # ssh mung
    # startx 
    services.xserver.displayManager.startx =
    { enable = true;
      generateScript = true;
    };

    # This is broken because it has a hardcoded --xvfb flag
    #   services.xserver.displayManager.xpra =
    # So we use a manually created service here
    # Create systemd service for xpra + xmonad
    #
    # TODO: renable once we have xmonad properly setup
    # systemd.services.xpra-xmonad = {
    #   description = "Xpra with XMonad on separate display";
    #   after = [ "multi-user.target" ];
    #   wantedBy = [ "multi-user.target" ];

    #   serviceConfig =
    #   { Type = "simple";
    #     User = "noah";  # CHANGE THIS to your actual username
    
    #     # Start X server on :1 (VT8) with XMonad, then attach xpra to it
    #     ExecStart =
    #     ''
    #       ${pkgs.xpra}/bin/xpra start-desktop :10 \
    #         --start=startxfce4 \
    #         --bind-tcp=0.0.0.0:14500 \
    #         --html=on \
    #         --daemon=no \
    #         --systemd-run=no
    #     '';
    
    #     Restart = "on-failure";
    #     RestartSec = "1s";
    
    #     # Environment variables
    #     Environment = "PATH=/run/current-system/sw/bin";
    #   };
    # };
    #...and we open the firewall to allow this port so we don't have to ssh tunnel
    # this might be a security risk
    networking.firewall.allowedTCPPorts = [ 14500 ];

    # this is needed so when using startx in an "ssh -X" session
    # we have permissions to run the xserver
    environment.etc."X11/Xwrapper.config" =
    { source = pkgs.writeText "Xwrapper.config"
      ''
      allowed_users=anybody
      needs_root_rights=no # yes|no|auto
      '';
      mode = "0666";
    };

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    #systemd.services."getty@tty1".enable = false;
    #systemd.services."autovt@tty1".enable = false;
    services.xserver.desktopManager.gnome.enable = false;
    services.xserver.desktopManager.xfce.enable = false;

    services.xserver.windowManager.xmonad =
    { enable = true;
      enableContribAndExtras = true;
      config =
      ''
        import XMonad
        import XMonad.Util.EZConfig (additionalKeys)
        import Control.Monad (when)
        import Text.Printf (printf)
        import System.Posix.Process (executeFile)
        import System.Info (arch,os)
        import System.Environment (getArgs)
        import System.FilePath ((</>))

        compiledConfig = printf "xmonad-%s-%s" arch os

        myConfig = def
          { modMask = controlMask -- For Use Super instead of Alt change to mod4Mask
          , terminal = "urxvt"
          }
          `additionalKeys`
          [ ( (controlMask,xK_r), compileRestart True)
          , ( (controlMask,xK_q), restart "xmonad" True )
          ]

        compileRestart resume = do
          dirs  <- asks directories
          whenX (recompile dirs True) $ do
            when resume writeStateToFile
            catchIO
                ( do
                    args <- getArgs
                    executeFile (cacheDir dirs </> compiledConfig) False args Nothing
                )

        main = getDirectories >>= launch myConfig
      '';
    };

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.noah = {
      isNormalUser = true;
      description = "noah";
      extraGroups = [ "networkmanager" "wheel" "tty" ];
      packages = with pkgs; [ helix ];
    };

    # Enable automatic login for the user.
    services.displayManager.autoLogin.enable = false;
    services.displayManager.autoLogin.user = "noah";


    # Install firefox.
    programs.firefox.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

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

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh =
      { enable = true;
        settings =
        { X11Forwarding = true;
        };
      };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.05"; # Did you read the comment?
  };
}


