{ flake.nixosModules.mung =
  { networking.hostName = "mung"; # Define your hostname.
    networking.hosts =
    { "192.168.1.49" = [ "lima" ];
    };

    # Enables wireless support via wpa_supplicant.
    # networking.wireless.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    # networking.networkmanager.enable = true;

    services.avahi =
    { enable = true;
      nssmdns4 = true;
      publish =
      { enable = true;
        addresses = true;
      };
    };
  };
}
