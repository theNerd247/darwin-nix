{withSystem, ...}:

{ flake.nixosModules.mung = withSystem "x86_64-linux" ({pkgs, ...}: 
  {
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
    # networking.firewall.allowedTCPPorts = [ 14500 ];
  });
}
