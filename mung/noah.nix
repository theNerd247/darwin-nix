{ flake.nixosModule.mung = 
  {
    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.noah = {
      isNormalUser = true;
      description = "noah";
      extraGroups = [ "networkmanager" "wheel" "tty" ];
    };
  };
}
