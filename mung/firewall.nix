{ flake.nixosModules.mung =
  {

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts =
    let
      ports = { ssh = 22; };
    in
      [ ports.ssh ];

    # networking.firewall.allowedUDPPorts = [ ... ];
     
    # Or disable the firewall altogether.
    # TODO: Rename able firewall
    networking.firewall.enable = false;

  };
}
