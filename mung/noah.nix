{ flake.nixosModules.mung = 
  {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.noah = {
      enable = true;
      home = /home/noah;
      isNormalUser = true;
      description = "noah";
      extraGroups = [ "networkmanager" "wheel" "tty" ];
    };
  };
}
