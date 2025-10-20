{ flake.nixosModules.mung =
  {

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.xserver.libinput.enable = true;

    # this is used to have x11 forwarding
    #
    # ssh mung
    # startx 
    services.xserver.displayManager.startx =
    { enable = true;
      generateScript = true;
    };

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

  };
}
