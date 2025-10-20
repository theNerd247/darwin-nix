{ flake.nixosModules.mung =
  { programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
