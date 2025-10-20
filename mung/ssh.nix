{ flake.nixosModules.mung =
  { # Enable the OpenSSH daemon.
    services.openssh =
    { enable = true;
      settings =
      { X11Forwarding = true;
      };
    };

    ssh.extraConfig =
    ''
    Host lima
      User noah
      HostName 192.168.1.49
    '';

    networking.hosts =
    { "192.168.1.49" = [ "lima" ];
    };

  };
}
